//
//  AuthRateLimiter.swift
//  CloudSyncApp
//
//  Implements authentication rate limiting with exponential backoff (#118)
//  Prevents brute-force attacks and respects provider rate limits
//

import Foundation
import OSLog

// MARK: - Auth Rate Limiter (#118)

/// Manages authentication rate limiting with exponential backoff per provider
/// Tracks failed attempts and enforces cooldown periods to prevent abuse
actor AuthRateLimiter {

    // MARK: - Singleton

    static let shared = AuthRateLimiter()

    // MARK: - Configuration

    /// Configuration for rate limiting behavior
    struct Config {
        /// Maximum failed attempts before lockout
        let maxAttempts: Int
        /// Base delay in seconds for exponential backoff
        let baseDelay: TimeInterval
        /// Maximum delay cap in seconds
        let maxDelay: TimeInterval
        /// Window in seconds after which attempts reset
        let resetWindow: TimeInterval

        static let `default` = Config(
            maxAttempts: 5,
            baseDelay: 2.0,
            maxDelay: 300.0,  // 5 minutes max
            resetWindow: 900.0  // 15 minutes
        )

        /// Stricter config for sensitive providers
        static let strict = Config(
            maxAttempts: 3,
            baseDelay: 5.0,
            maxDelay: 600.0,  // 10 minutes max
            resetWindow: 1800.0  // 30 minutes
        )
    }

    // MARK: - State Tracking

    /// Tracks authentication state for a provider
    private struct AuthState {
        var failedAttempts: Int = 0
        var lastFailure: Date?
        var lastSuccess: Date?
        var lockedUntil: Date?

        /// Check if currently locked out
        var isLocked: Bool {
            guard let until = lockedUntil else { return false }
            return Date() < until
        }

        /// Calculate remaining lockout time in seconds
        var remainingLockoutTime: TimeInterval {
            guard let until = lockedUntil else { return 0 }
            return max(0, until.timeIntervalSinceNow)
        }
    }

    // MARK: - Properties

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.cloudsync.ultra", category: "AuthRateLimiter")
    private var providerStates: [String: AuthState] = [:]
    private let config: Config

    // MARK: - Initialization

    private init(config: Config = .default) {
        self.config = config
    }

    // MARK: - Public API

    /// Check if authentication is allowed for a provider
    /// - Parameter provider: Provider identifier (e.g., "proton", "google", "dropbox")
    /// - Returns: True if auth is allowed, false if rate limited
    func canAttemptAuth(for provider: String) -> Bool {
        let state = providerStates[provider, default: AuthState()]

        // Check if locked
        if state.isLocked {
            logger.warning("Auth blocked for \(provider, privacy: .public): locked for \(Int(state.remainingLockoutTime))s")
            return false
        }

        // Check if attempts reset due to window expiry
        if let lastFailure = state.lastFailure,
           Date().timeIntervalSince(lastFailure) > config.resetWindow {
            // Window expired, reset state
            return true
        }

        // Check attempt count
        if state.failedAttempts >= config.maxAttempts {
            logger.warning("Auth blocked for \(provider, privacy: .public): max attempts reached")
            return false
        }

        return true
    }

    /// Record a failed authentication attempt
    /// - Parameter provider: Provider identifier
    /// - Returns: Delay before next attempt is allowed (in seconds)
    @discardableResult
    func recordFailure(for provider: String) -> TimeInterval {
        var state = providerStates[provider, default: AuthState()]

        state.failedAttempts += 1
        state.lastFailure = Date()

        // Calculate exponential backoff delay
        // Formula: baseDelay * 2^(attempts-1), capped at maxDelay
        let exponent = min(state.failedAttempts - 1, 10)  // Cap exponent to prevent overflow
        let delay = min(config.baseDelay * pow(2.0, Double(exponent)), config.maxDelay)

        // Set lockout if max attempts reached
        if state.failedAttempts >= config.maxAttempts {
            state.lockedUntil = Date().addingTimeInterval(delay)
            logger.error("Provider \(provider, privacy: .public) locked for \(Int(delay))s after \(state.failedAttempts) failed attempts")
        } else {
            logger.warning("Auth failed for \(provider, privacy: .public): attempt \(state.failedAttempts)/\(self.config.maxAttempts), next delay: \(Int(delay))s")
        }

        providerStates[provider] = state
        return delay
    }

    /// Record a successful authentication
    /// - Parameter provider: Provider identifier
    func recordSuccess(for provider: String) {
        // Reset state on success
        providerStates[provider] = AuthState(lastSuccess: Date())
        logger.info("Auth succeeded for \(provider, privacy: .public), state reset")
    }

    /// Get current status for a provider
    /// - Parameter provider: Provider identifier
    /// - Returns: Tuple of (isLocked, failedAttempts, remainingLockoutSeconds)
    func getStatus(for provider: String) -> (isLocked: Bool, failedAttempts: Int, remainingLockout: TimeInterval) {
        let state = providerStates[provider, default: AuthState()]
        return (state.isLocked, state.failedAttempts, state.remainingLockoutTime)
    }

    /// Reset rate limiting state for a provider (use sparingly)
    /// - Parameter provider: Provider identifier
    func reset(for provider: String) {
        providerStates.removeValue(forKey: provider)
        logger.info("Rate limit state reset for \(provider, privacy: .public)")
    }

    /// Reset all rate limiting state
    func resetAll() {
        providerStates.removeAll()
        logger.info("All rate limit states reset")
    }

    /// Wait for rate limit cooldown if needed
    /// - Parameter provider: Provider identifier
    /// - Throws: AuthRateLimitError if permanently blocked
    func waitIfNeeded(for provider: String) async throws {
        let state = providerStates[provider, default: AuthState()]

        if state.isLocked {
            let waitTime = state.remainingLockoutTime
            if waitTime > 0 {
                logger.info("Waiting \(Int(waitTime))s for rate limit cooldown on \(provider, privacy: .public)")
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
    }
}

// MARK: - Auth Rate Limit Error

enum AuthRateLimitError: LocalizedError {
    case rateLimited(provider: String, retryAfter: TimeInterval)
    case maxAttemptsExceeded(provider: String)

    var errorDescription: String? {
        switch self {
        case .rateLimited(let provider, let retryAfter):
            return "Authentication for \(provider) is rate limited. Please wait \(Int(retryAfter)) seconds."
        case .maxAttemptsExceeded(let provider):
            return "Maximum authentication attempts exceeded for \(provider). Please try again later."
        }
    }
}

// MARK: - Provider-Specific Rate Limiting

extension AuthRateLimiter {

    /// Get provider-specific configuration
    /// Some providers (like Proton) are more sensitive to rate limiting
    static func config(for provider: String) -> Config {
        let sensitiveProviders = ["proton", "protondrive"]

        if sensitiveProviders.contains(provider.lowercased()) {
            return .strict
        }

        return .default
    }
}
