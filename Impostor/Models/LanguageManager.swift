//
//  LanguageManager.swift
//  Impostor
//
//  Created by Language Picker Implementation
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
    }
    
    private init() {
        // Load saved language or determine default
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        self.selectedLanguage = savedLanguage ?? Self.determineDefaultLanguage()
    }
    
    /// Get all available languages from the bundle
    var availableLanguages: [String] {
        guard let resourcePath = Bundle.main.resourcePath else { return ["en"] }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            let languages = contents
                .filter { $0.hasSuffix(".lproj") }
                .map { String($0.dropSuffix(".lproj".count)) }
                .sorted()
            
            return languages.isEmpty ? ["en"] : languages
        } catch {
            print("Error reading available languages: \(error)")
            return ["en"]
        }
    }
    
    /// Get display name for a language code
    func displayName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        let displayName = locale.localizedString(forIdentifier: languageCode) ?? 
                         Locale.current.localizedString(forIdentifier: languageCode) ??
                         languageCode
        
        // Capitalize first letter for better display
        return displayName.prefix(1).capitalized + displayName.dropFirst()
    }
    
    /// Determine default language based on priority:
    /// 1. System preferred language #1 (if available)
    /// 2. System preferred language #2 (if available) 
    /// 3. English
    private static func determineDefaultLanguage() -> String {
        // Get available languages directly from bundle
        guard let resourcePath = Bundle.main.resourcePath else { return "en" }
        
        let availableLanguages: [String]
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            availableLanguages = contents
                .filter { $0.hasSuffix(".lproj") }
                .map { String($0.dropSuffix(".lproj".count)) }
                .sorted()
        } catch {
            print("Error reading available languages: \(error)")
            return "en"
        }
        
        // Check system preferred languages in order
        for preferredLanguage in Locale.preferredLanguages {
            // Try exact match first
            if availableLanguages.contains(preferredLanguage) {
                return preferredLanguage
            }
            
            // Try language code without region
            let languageCode = String(preferredLanguage.prefix(2))
            if availableLanguages.contains(languageCode) {
                return languageCode
            }
        }
        
        // Fall back to English
        return availableLanguages.contains("en") ? "en" : (availableLanguages.first ?? "en")
    }
    
    /// Apply the selected language to the app
    func applyLanguage() {
        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Note: Language change typically requires app restart to take full effect
        // For immediate UI updates, we'd need to implement manual localization
    }
}