//
//  HelpManager.swift
//  CloudSyncApp
//
//  Manages help topics and provides search functionality
//

import Foundation

class HelpManager: ObservableObject {
    static let shared = HelpManager()

    @Published private(set) var topics: [HelpTopic] = []

    private init() {
        loadHelpTopics()
    }

    // MARK: - Data Loading

    private func loadHelpTopics() {
        topics = [
            // MARK: - Getting Started Topics

            HelpTopic(
                title: "Welcome to CloudSync Ultra",
                content: """
                CloudSync Ultra is a powerful macOS application that helps you sync and manage files across multiple cloud storage providers.

                Key Features:
                • Connect to 60+ cloud storage providers
                • Sync files between any cloud services
                • End-to-end encryption support
                • Schedule automatic syncs
                • Monitor transfer progress in real-time
                • Fast and efficient rclone-powered transfers

                To get started:
                1. Add your first cloud provider from the sidebar
                2. Configure authentication
                3. Browse your files or create a sync task
                4. Monitor your transfers in the Tasks panel

                Need help? Browse topics by category or use the search feature to find specific information.
                """,
                category: .gettingStarted,
                keywords: ["welcome", "introduction", "overview", "start", "begin", "features"],
                sortOrder: 0
            ),

            HelpTopic(
                title: "Adding Your First Cloud Provider",
                content: """
                CloudSync Ultra supports over 60 cloud storage providers including Google Drive, Dropbox, OneDrive, iCloud, and many more.

                To add a provider:
                1. Click the + button in the sidebar under "My Remotes"
                2. Select your cloud provider from the list
                3. Enter a friendly name for this connection
                4. Complete the authentication process:
                   • OAuth providers (Google, Dropbox): Browser window opens for login
                   • Credential-based providers: Enter your access keys or credentials
                   • Local/Network providers: Enter path or server details

                After configuration:
                • Your provider appears in the sidebar
                • Click it to browse files
                • Use it as source or destination for sync tasks

                Tip: You can add multiple accounts from the same provider by giving them different names.
                """,
                category: .gettingStarted,
                keywords: ["add", "connect", "provider", "setup", "configure", "authentication", "oauth"],
                sortOrder: 1
            ),

            HelpTopic(
                title: "Understanding the Interface",
                content: """
                CloudSync Ultra has a clean, intuitive interface with four main areas:

                1. Sidebar (Left)
                   • My Remotes: Your configured cloud providers
                   • Quick Actions: Common operations
                   • Click any remote to browse files

                2. File Browser (Center)
                   • Browse files and folders in selected remote
                   • Double-click folders to navigate
                   • Use breadcrumb navigation at top
                   • Drag and drop to transfer files

                3. Tasks Panel (Right)
                   • View active and completed transfers
                   • Monitor progress and speed
                   • Pause, resume, or cancel tasks
                   • View detailed task information

                4. Status Bar (Bottom)
                   • Connection status for each provider
                   • Quick stats about your remotes
                   • System notifications

                Navigation Tips:
                • Use ⌘F to search within help
                • Click account icons for quick access
                • Hover over items for tooltips
                """,
                category: .gettingStarted,
                keywords: ["interface", "ui", "navigation", "sidebar", "browser", "tasks", "layout"],
                sortOrder: 2
            ),

            // MARK: - Cloud Providers Topics

            HelpTopic(
                title: "Supported Cloud Providers",
                content: """
                CloudSync Ultra supports 60+ cloud storage providers across multiple categories:

                Popular Providers:
                • Google Drive, Dropbox, OneDrive, iCloud Drive
                • Box, MEGA, pCloud, Proton Drive

                Object Storage:
                • Amazon S3, Backblaze B2, Wasabi
                • Cloudflare R2, DigitalOcean Spaces
                • Google Cloud Storage, Azure Blob

                Self-Hosted Solutions:
                • Nextcloud, ownCloud, Seafile
                • WebDAV, SFTP, FTP

                Enterprise Services:
                • OneDrive for Business, SharePoint
                • Azure Files, Alibaba Cloud OSS

                International Providers:
                • Yandex Disk, Mail.ru Cloud
                • Jottacloud, Koofr

                Each provider may have different:
                • Authentication methods (OAuth, API keys, credentials)
                • Feature support (encryption, versioning)
                • Performance characteristics
                • Storage limits and quotas

                Check each provider's documentation for specific requirements and capabilities.
                """,
                category: .providers,
                keywords: ["providers", "supported", "cloud", "services", "list", "google", "dropbox", "onedrive", "icloud", "s3"],
                sortOrder: 0
            ),

            HelpTopic(
                title: "OAuth Authentication",
                content: """
                Many cloud providers use OAuth for secure authentication. This includes Google Drive, Dropbox, OneDrive, Box, and others.

                OAuth Authentication Process:
                1. Click to add an OAuth-enabled provider
                2. A browser window opens automatically
                3. Sign in to your cloud account
                4. Grant CloudSync Ultra access permissions
                5. Browser closes automatically
                6. Provider is now connected and ready to use

                Security Notes:
                • CloudSync never sees your password
                • Access can be revoked from provider's settings
                • Tokens are securely stored in macOS Keychain
                • Each provider connection is independent

                Troubleshooting OAuth:
                • If browser doesn't open, check default browser settings
                • Ensure pop-ups are not blocked
                • Try signing out and back into your cloud account
                • Check internet connectivity
                • Verify date/time settings are correct

                Revoking Access:
                • Google: myaccount.google.com/permissions
                • Dropbox: dropbox.com/account/connected_apps
                • OneDrive: account.live.com/consent/Manage
                """,
                category: .providers,
                keywords: ["oauth", "authentication", "login", "sign in", "browser", "token", "authorize", "permission"],
                sortOrder: 1
            ),

            HelpTopic(
                title: "Managing Multiple Accounts",
                content: """
                CloudSync Ultra allows you to connect multiple accounts from the same provider. This is useful for:
                • Personal and work accounts
                • Multiple team accounts
                • Different storage tiers
                • Organizational separation

                Adding Multiple Accounts:
                1. Add provider normally (e.g., "Work Google Drive")
                2. Complete authentication for first account
                3. Add same provider again with different name (e.g., "Personal Google Drive")
                4. Authenticate with different credentials
                5. Both accounts appear separately in sidebar

                Managing Accounts:
                • Each account has its own icon and name
                • Rename accounts anytime from settings
                • Remove accounts without affecting others
                • Set different encryption settings per account

                Transfer Between Accounts:
                • Create sync task between two accounts
                • Drag files from one account to another
                • Schedule regular syncs between accounts

                Best Practices:
                • Use descriptive names (Work, Personal, Team, etc.)
                • Organize with consistent naming conventions
                • Use encryption for sensitive accounts
                • Regular sync for backup purposes
                """,
                category: .providers,
                keywords: ["multiple", "accounts", "several", "many", "work", "personal", "team"],
                sortOrder: 2
            ),

            // MARK: - Syncing Topics

            HelpTopic(
                title: "Creating a Sync Task",
                content: """
                Sync tasks transfer files between cloud providers automatically.

                Creating a Sync Task:
                1. Click "New Sync Task" or use Quick Actions
                2. Select source provider and folder
                3. Select destination provider and folder
                4. Choose sync type:
                   • Sync: Keep folders identical (two-way)
                   • Transfer: One-way copy
                   • Backup: One-way with versioning
                5. Configure options (encryption, scheduling, filters)
                6. Click "Create Task" to save

                Sync Types Explained:

                Sync (Bidirectional):
                • Changes on either side are synchronized
                • New files copied to other side
                • Deleted files removed from both sides
                • Modified files updated everywhere

                Transfer (One-way):
                • Files copied from source to destination
                • Destination changes not copied back
                • Good for backups or migrations

                Backup:
                • Like transfer but keeps file versions
                • Deleted files retained in destination
                • Safer for important data

                Task Options:
                • Enable encryption for secure transfers
                • Set up scheduling for automatic syncs
                • Add file filters (include/exclude patterns)
                • Configure bandwidth limits
                • Set up notifications
                """,
                category: .syncing,
                keywords: ["sync", "task", "create", "transfer", "backup", "copy", "move"],
                sortOrder: 0
            ),

            HelpTopic(
                title: "Monitoring Transfer Progress",
                content: """
                CloudSync Ultra provides detailed real-time information about your transfers.

                Tasks Panel Information:
                • Task name and type
                • Current status (Running, Completed, Failed)
                • Progress bar with percentage
                • Files transferred (current/total)
                • Data transferred (MB/GB)
                • Transfer speed (MB/s)
                • Estimated time remaining
                • Source and destination

                Transfer States:

                Pending: Task created but not started
                Running: Actively transferring files
                Paused: Temporarily stopped by user
                Completed: Successfully finished
                Failed: Encountered error (see details)
                Cancelled: Stopped by user

                Progress Details:
                • Click task to see full details
                • View file-by-file progress
                • See real-time transfer statistics
                • Check error logs if issues occur

                Controlling Transfers:
                • Pause: Temporarily stop (can resume)
                • Resume: Continue paused transfer
                • Cancel: Stop and remove task
                • Retry: Restart failed transfer

                Performance Tips:
                • Multiple tasks run in parallel
                • Large files show more accurate progress
                • Many small files may show in batches
                • Network speed affects transfer rates
                """,
                category: .syncing,
                keywords: ["progress", "monitor", "status", "transfer", "speed", "eta", "tracking"],
                sortOrder: 1
            ),

            HelpTopic(
                title: "Scheduling Automatic Syncs",
                content: """
                Schedule tasks to run automatically at specified intervals, keeping your files synchronized without manual intervention.

                Setting Up Scheduled Syncs:
                1. Create or edit a sync task
                2. Enable "Schedule this task"
                3. Choose sync interval:
                   • Every hour
                   • Every 6 hours
                   • Daily (once per day)
                   • Weekly (once per week)
                4. Set preferred time for daily/weekly syncs
                5. Save task

                How Scheduled Syncs Work:
                • Tasks run automatically at specified times
                • Must keep CloudSync Ultra running
                • Can run in background
                • Notifications when sync completes
                • Skip if previous sync still running

                Managing Scheduled Tasks:
                • View next run time in task details
                • Disable schedule without deleting task
                • Run manually anytime between scheduled syncs
                • Change schedule frequency anytime
                • View history of past syncs

                Best Practices:
                • Use hourly for frequently changing files
                • Use daily for regular backups
                • Use weekly for archives or large datasets
                • Avoid scheduling many tasks simultaneously
                • Test schedule with manual run first

                Background Operation:
                • CloudSync Ultra can run in menu bar
                • Scheduled tasks work in background
                • Notifications alert you of completion
                • View status from menu bar icon
                """,
                category: .syncing,
                keywords: ["schedule", "automatic", "recurring", "interval", "daily", "weekly", "hourly"],
                sortOrder: 2
            ),

            // MARK: - Security Topics

            HelpTopic(
                title: "End-to-End Encryption",
                content: """
                CloudSync Ultra supports end-to-end encryption, keeping your files private even from cloud providers.

                How Encryption Works:
                • Files encrypted on your Mac before upload
                • Cloud provider stores only encrypted data
                • Only you have the decryption password
                • Files decrypted only on your devices
                • Provider cannot read your files

                Setting Up Encryption:
                1. Select a cloud remote
                2. Enable "Encrypt this remote"
                3. Create a strong encryption password
                4. Confirm password
                5. CloudSync creates encrypted remote
                6. Use this remote for sensitive files

                Encryption Features:
                • AES-256 encryption standard
                • File names and content encrypted
                • Directory structure obscured
                • No provider access to data
                • Password never leaves your Mac

                Important Notes:
                ⚠️ Password cannot be recovered if lost
                ⚠️ Write down password securely
                ⚠️ Files only accessible with correct password
                ⚠️ Encryption adds minimal performance overhead

                Best Practices:
                • Use encryption for sensitive data
                • Create strong, unique passwords
                • Store password in secure location
                • Don't share encrypted remotes without password
                • Consider using password manager

                Encrypted Transfers:
                • Enable encryption on source, destination, or both
                • Mix encrypted and unencrypted remotes
                • Transfer between different encrypted remotes
                • Each remote has independent encryption
                """,
                category: .security,
                keywords: ["encryption", "security", "privacy", "password", "encrypted", "aes", "secure"],
                sortOrder: 0
            ),

            HelpTopic(
                title: "Password Management",
                content: """
                CloudSync Ultra securely stores your credentials using macOS Keychain.

                Credential Storage:
                • All passwords stored in macOS Keychain
                • Encrypted by macOS automatically
                • Protected by your Mac login
                • Never stored in plain text
                • Synchronized via iCloud Keychain (optional)

                Types of Stored Credentials:
                • OAuth tokens for providers
                • API keys and access tokens
                • Encryption passwords
                • SFTP/FTP login details
                • WebDAV credentials

                Security Features:
                • System-level encryption
                • Protected by macOS security
                • Isolated per application
                • Can be backed up with Time Machine
                • Cleared when app uninstalled

                Managing Credentials:
                • Keychain Access app shows stored items
                • Can remove individual credentials
                • Re-authenticate updates credentials
                • Changing password requires re-auth

                If Credentials Are Lost:
                1. Remove provider from CloudSync
                2. Delete keychain items (if needed)
                3. Re-add provider
                4. Complete authentication again

                Best Practices:
                • Keep macOS up to date
                • Use strong Mac login password
                • Enable FileVault for disk encryption
                • Regular backups with Time Machine
                • Review keychain items periodically
                """,
                category: .security,
                keywords: ["password", "credentials", "keychain", "storage", "secure", "authentication"],
                sortOrder: 1
            ),

            // MARK: - Troubleshooting Topics

            HelpTopic(
                title: "Common Sync Errors",
                content: """
                Here are solutions to common sync errors you might encounter:

                Authentication Errors:
                • "Invalid credentials" or "Access denied"
                • Solution: Re-authenticate provider
                • Go to provider settings
                • Click "Re-authenticate" or remove and re-add

                Network Errors:
                • "Connection timeout" or "Network unreachable"
                • Solution: Check internet connection
                • Verify provider service status
                • Try again after a few minutes
                • Check firewall settings

                Permission Errors:
                • "Access denied" or "Insufficient permissions"
                • Solution: Check folder permissions
                • Verify account has access to folders
                • Re-authorize app if using OAuth
                • Check provider's sharing settings

                Storage Full:
                • "Insufficient storage" or "Quota exceeded"
                • Solution: Free up space in destination
                • Check account storage limits
                • Remove unnecessary files
                • Upgrade storage plan if needed

                File Conflicts:
                • "File already exists" or "Conflict detected"
                • Solution: Use sync instead of transfer
                • Enable conflict resolution
                • Manually resolve conflicting files
                • Check sync direction settings

                Rate Limiting:
                • "Too many requests" or "Rate limit exceeded"
                • Solution: Wait and try again
                • Reduce number of concurrent transfers
                • Some providers limit API calls
                • Retry automatically after delay

                General Troubleshooting:
                1. Check task error message for details
                2. Verify both source and destination work
                3. Try smaller test transfer first
                4. Check provider service status online
                5. Review CloudSync logs for more info
                6. Restart app if issues persist
                """,
                category: .troubleshooting,
                keywords: ["error", "fail", "problem", "issue", "fix", "troubleshoot", "network", "authentication", "permission"],
                sortOrder: 0
            ),

            HelpTopic(
                title: "Improving Transfer Speeds",
                content: """
                If transfers are slower than expected, try these optimization tips:

                Network Optimization:
                • Use wired connection instead of WiFi
                • Close bandwidth-heavy applications
                • Pause other downloads/uploads
                • Check your internet speed
                • Contact ISP if speeds consistently low

                CloudSync Settings:
                • Reduce number of concurrent transfers
                • Adjust transfer chunk size
                • Enable compression for text files
                • Disable encryption if not needed
                • Use local caching when available

                Provider-Specific:
                • Some providers have rate limits
                • Business accounts often faster
                • Choose nearby data center/region
                • Check provider status page
                • Upgrade account tier if available

                File Optimization:
                • Large files transfer faster per byte
                • Many small files slower overall
                • Compress before transferring
                • Archive folders into single file
                • Remove temporary files

                System Resources:
                • Close unnecessary applications
                • Ensure sufficient RAM available
                • Check CPU usage (Activity Monitor)
                • Verify sufficient disk space
                • Restart Mac if sluggish

                Time-of-Day Factors:
                • Transfer during off-peak hours
                • Early morning often fastest
                • Avoid peak evening hours
                • Consider provider's timezone

                Expected Speeds:
                • Typical: 5-20 MB/s for good connections
                • Home broadband: limited by upload speed
                • Business: usually faster both ways
                • Provider limits may apply
                • Distance to servers affects speed

                Monitoring Performance:
                • Check real-time transfer speed
                • Compare across different providers
                • Test with various file types
                • Note patterns (time of day, file size)
                """,
                category: .troubleshooting,
                keywords: ["slow", "speed", "performance", "fast", "faster", "optimize", "bandwidth"],
                sortOrder: 1
            ),

            HelpTopic(
                title: "Connection Issues",
                content: """
                If you're having trouble connecting to cloud providers:

                Basic Checks:
                • Verify internet connection works
                • Try accessing provider's website
                • Check provider service status
                • Ensure CloudSync Ultra is up to date
                • Restart CloudSync Ultra

                OAuth Connection Issues:
                • Browser doesn't open: Check default browser
                • Login fails: Try different browser
                • Access denied: Check app permissions
                • Token expired: Re-authenticate provider
                • Pop-up blocked: Allow pop-ups for CloudSync

                Credential-Based Issues:
                • Invalid API key: Verify copied correctly
                • Access denied: Check key permissions
                • Key expired: Generate new key
                • Account locked: Check provider account
                • Wrong endpoint: Verify server URL

                Network Configuration:
                • Firewall blocking CloudSync
                • VPN interfering with connection
                • Proxy settings incorrect
                • Corporate network restrictions
                • DNS resolution problems

                Solutions:

                For Firewall Issues:
                1. Open System Settings
                2. Privacy & Security → Firewall
                3. Add CloudSync Ultra to allowed apps
                4. Ensure incoming connections allowed

                For VPN Issues:
                1. Try disabling VPN temporarily
                2. Add provider domains to VPN exceptions
                3. Use VPN with appropriate region
                4. Contact VPN provider for help

                For Proxy Issues:
                1. Check System Settings → Network → Proxies
                2. Add proxy exceptions for providers
                3. Try disabling proxy temporarily
                4. Verify proxy credentials if required

                Advanced Diagnostics:
                • Check Console app for errors
                • Review CloudSync logs
                • Test with curl or browser
                • Try different network
                • Contact provider support

                Still Having Issues?
                • Check provider documentation
                • Visit provider status page
                • Try removing and re-adding provider
                • Restart Mac
                • Contact CloudSync support with error details
                """,
                category: .troubleshooting,
                keywords: ["connection", "connect", "network", "offline", "unreachable", "firewall", "vpn", "proxy"],
                sortOrder: 2
            ),

            // MARK: - Advanced Topics

            HelpTopic(
                title: "Using rclone Commands",
                content: """
                CloudSync Ultra is powered by rclone, a powerful command-line tool. Advanced users can access rclone directly.

                What is rclone?
                • Open-source cloud storage manager
                • Supports 40+ cloud providers
                • Efficient transfer engine
                • Extensive configuration options
                • Command-line interface

                CloudSync + rclone:
                • CloudSync uses rclone internally
                • Providers configured as rclone remotes
                • Tasks execute as rclone commands
                • Config stored in rclone format
                • Can use rclone CLI alongside CloudSync

                Accessing rclone:
                • CloudSync installs rclone automatically
                • Location: CloudSync bundle
                • Can use Terminal with rclone commands
                • Config at: ~/.config/rclone/rclone.conf

                Common rclone Commands:

                List remotes:
                rclone listremotes

                List files:
                rclone ls remotename:path

                Copy files:
                rclone copy source:path dest:path

                Sync folders:
                rclone sync source:path dest:path

                Check differences:
                rclone check source:path dest:path

                Advanced Operations:
                • Custom transfer flags
                • Bandwidth limiting
                • File filtering with patterns
                • Checksums and verification
                • Server-side operations

                CloudSync Remote Names:
                • Provider name (lowercase, no spaces)
                • Encrypted remotes: provider-crypt
                • Example: googledrive, dropbox-crypt

                Combining GUI and CLI:
                • Configure in CloudSync GUI
                • Use CLI for advanced operations
                • Both use same config file
                • Changes in one affect the other
                • GUI provides visual monitoring

                Learning More:
                • rclone.org for documentation
                • rclone forum for community help
                • GitHub for issues and examples
                • CloudSync respects rclone settings
                """,
                category: .advanced,
                keywords: ["rclone", "command", "cli", "terminal", "advanced", "command-line"],
                sortOrder: 0
            )
        ]
    }

    // MARK: - Search Functionality

    /// Search topics by query string
    func search(query: String) -> [HelpTopic] {
        guard !query.isEmpty else {
            return topics
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return topics
        }

        // Find matching topics
        let matchingTopics = topics.filter { topic in
            topic.matches(query: trimmedQuery)
        }

        // Sort by relevance score (highest first)
        let sortedTopics = matchingTopics.sorted { topic1, topic2 in
            let score1 = topic1.relevanceScore(for: trimmedQuery)
            let score2 = topic2.relevanceScore(for: trimmedQuery)
            return score1 > score2
        }

        return sortedTopics
    }

    /// Get topics by category
    func topics(for category: HelpCategory) -> [HelpTopic] {
        topics
            .filter { $0.category == category }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Get all topics organized by category
    func topicsByCategory() -> [(category: HelpCategory, topics: [HelpTopic])] {
        HelpCategory.allCases.map { category in
            (category: category, topics: topics(for: category))
        }
    }

    /// Get a specific topic by ID
    func topic(withId id: UUID) -> HelpTopic? {
        topics.first { $0.id == id }
    }

    /// Get related topics for a given topic
    func relatedTopics(for topic: HelpTopic) -> [HelpTopic] {
        guard let relatedIds = topic.relatedTopicIds else {
            // If no explicit relations, return topics from same category
            return topics(for: topic.category).filter { $0.id != topic.id }
        }

        return relatedIds.compactMap { id in
            self.topic(withId: id)
        }
    }

    // MARK: - Statistics

    var totalTopics: Int {
        topics.count
    }

    func topicCount(for category: HelpCategory) -> Int {
        topics.filter { $0.category == category }.count
    }
}
