//
//  LanguageManagerTests.swift
//  ImpostorTests
//
//  Created by Language Picker Implementation
//

import XCTest
@testable import Impostor

final class LanguageManagerTests: XCTestCase {
    
    func testLanguageManagerInitialization() {
        let manager = LanguageManager.shared
        XCTAssertNotNil(manager.selectedLanguage)
        XCTAssertFalse(manager.selectedLanguage.isEmpty)
    }
    
    func testAvailableLanguages() {
        let manager = LanguageManager.shared
        let languages = manager.availableLanguages
        
        XCTAssertFalse(languages.isEmpty)
        XCTAssertTrue(languages.contains("en"))
        
        // Check that we have the expected languages from the repository
        let expectedLanguages = ["ar", "ca", "cs", "da", "de", "el", "en", "en-AU", "en-GB", 
                                "en-IN", "es", "es-419", "fi", "fr", "fr-CA", "he", "hi", 
                                "hr", "hu", "id", "it", "ja", "ko", "ms", "nb", "nl", "pl", 
                                "pt-BR", "pt-PT", "ro", "ru", "sk", "sv", "th", "tr", "uk", 
                                "vi", "zh-HK", "zh-Hans", "zh-Hant"]
        
        for expectedLang in expectedLanguages {
            XCTAssertTrue(languages.contains(expectedLang), "Missing language: \(expectedLang)")
        }
    }
    
    func testDisplayNameGeneration() {
        let manager = LanguageManager.shared
        
        // Test some basic language codes
        let englishName = manager.displayName(for: "en")
        XCTAssertFalse(englishName.isEmpty)
        
        let spanishName = manager.displayName(for: "es")
        XCTAssertFalse(spanishName.isEmpty)
        
        // Test that display names are not just the language codes
        XCTAssertNotEqual(englishName, "en")
        XCTAssertNotEqual(spanishName, "es")
    }
    
    func testLanguageSelection() {
        let manager = LanguageManager.shared
        let originalLanguage = manager.selectedLanguage
        
        // Test selecting a different language
        let newLanguage = "es"
        manager.selectedLanguage = newLanguage
        XCTAssertEqual(manager.selectedLanguage, newLanguage)
        
        // Restore original language
        manager.selectedLanguage = originalLanguage
        XCTAssertEqual(manager.selectedLanguage, originalLanguage)
    }
}