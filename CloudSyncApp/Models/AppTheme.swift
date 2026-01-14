//
//  AppTheme.swift
//  CloudSyncApp
//
//  Design system and theme constants
//  NOTE: This file provides backward compatibility.
//  The comprehensive theme is in Styles/AppTheme.swift
//

import SwiftUI

// MARK: - Legacy compatibility re-exports
// All definitions are now in Styles/AppTheme.swift, Styles/ButtonStyles.swift, and Styles/CardStyles.swift
// This file is kept for backward compatibility with existing code that imports from Models/

// The following types are now defined in:
// - AppTheme -> Styles/AppTheme.swift
// - AppColors -> Styles/AppTheme.swift
// - AppDimensions -> Styles/AppTheme.swift
// - PrimaryButtonStyle -> Styles/ButtonStyles.swift
// - SecondaryButtonStyle -> Styles/ButtonStyles.swift
// - CardStyle -> Styles/CardStyles.swift
// - SidebarItemStyle -> Styles/CardStyles.swift
// - Color.init(hex:) -> Styles/AppTheme.swift

// Note: Since Swift doesn't support re-exporting, we keep this file empty
// The actual implementations are in the Styles folder and will be found
// by the compiler due to being in the same target/module.
