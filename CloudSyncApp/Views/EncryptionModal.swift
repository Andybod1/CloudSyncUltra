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
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 32)
                    
                    Text("Confirm password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    SecureField("Confirm password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 32)
                }
                
                Text("If you lost this password you won't be able to unencrypt the files")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                .disabled(password.isEmpty || confirmPassword.isEmpty || isProcessing)
            }
            .padding()
        }
        .frame(width: 450, height: 400)
    }
    
    private func configureEncryption() {
        errorMessage = nil
        
        // Validation
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard password == confirmPassword else {
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
