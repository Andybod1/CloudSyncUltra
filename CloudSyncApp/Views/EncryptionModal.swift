//
//  EncryptionModal.swift
//  CloudSyncApp
//
//  Modal for configuring encryption - inspired by Jottacloud
//

import SwiftUI

struct EncryptionModal: View {
    @Environment(\.dismiss) private var dismiss
    
    var onConfirm: (EncryptionConfig) -> Void
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var encryptFilenames = true
    @State private var encryptFolders = true
    @State private var errorMessage: String?
    @State private var isProcessing = false
    
    // Password validation states
    private var passwordsMatch: Bool {
        !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    private var passwordLongEnough: Bool {
        password.count >= 8
    }
    
    private var canSubmit: Bool {
        passwordLongEnough && passwordsMatch && !isProcessing
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Encrypt Uploads")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            VStack(alignment: .leading, spacing: 20) {
                Text("Encrypt all uploads to your account in this session with the following password")
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Password field with strength indicator
                    HStack {
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 32)
                        
                        if !password.isEmpty {
                            Image(systemName: passwordLongEnough ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passwordLongEnough ? .green : .red)
                                .help(passwordLongEnough ? "Password is long enough" : "Password must be at least 8 characters")
                        }
                    }
                    
                    // Password length indicator
                    if !password.isEmpty && !passwordLongEnough {
                        Text("\(password.count)/8 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Text("Confirm password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Confirm password field with match indicator
                    HStack {
                        SecureField("Confirm password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 32)
                        
                        if !confirmPassword.isEmpty {
                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passwordsMatch ? .green : .red)
                                .help(passwordsMatch ? "Passwords match" : "Passwords do not match")
                        }
                    }
                    
                    // Match status text
                    if !confirmPassword.isEmpty {
                        HStack(spacing: 4) {
                            if passwordsMatch {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                Text("Passwords match")
                                    .font(.caption)
                            } else {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                Text("Passwords do not match")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(passwordsMatch ? .green : .red)
                    }
                }
                
                Text("If you lost this password you won't be able to unencrypt the files")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Encrypt file names", isOn: $encryptFilenames)
                    Toggle("Encrypt folder names", isOn: $encryptFolders)
                }
                
                if let error = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            .padding(20)
            
            Divider()
            
            // Footer buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.horizontal, 8)
                }
                
                Button("OK") {
                    configureEncryption()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
                .disabled(!canSubmit)
            }
            .padding()
        }
        .frame(width: 450, height: 420)
    }
    
    private func configureEncryption() {
        errorMessage = nil
        
        // Double-check validation (should already be valid due to button state)
        guard passwordLongEnough else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard passwordsMatch else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isProcessing = true
        
        // Create config
        let config = EncryptionConfig(
            password: password,
            encryptFilenames: encryptFilenames,
            encryptFolders: encryptFolders
        )
        
        // Call completion handler
        onConfirm(config)
        
        // Close modal
        dismiss()
    }
}

struct EncryptionConfig {
    let password: String
    let encryptFilenames: Bool
    let encryptFolders: Bool
    
    var filenameEncryptionMode: String {
        encryptFilenames ? "standard" : "off"
    }
}

#Preview {
    EncryptionModal { config in
        print("Encryption configured:")
        print("  Encrypt filenames: \(config.encryptFilenames)")
        print("  Encrypt folders: \(config.encryptFolders)")
    }
}
