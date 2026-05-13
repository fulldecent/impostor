//
//  LanguagePicker.swift
//  Impostor
//
//  Created by Language Picker Implementation
//

import SwiftUI

struct LanguagePicker: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languageManager.availableLanguages, id: \.self) { languageCode in
                    HStack {
                        Text(languageManager.displayName(for: languageCode))
                            .font(.custom("American Typewriter", size: 18))
                        
                        Spacer()
                        
                        if languageCode == languageManager.selectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        languageManager.selectedLanguage = languageCode
                        languageManager.applyLanguage()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("American Typewriter", size: 16))
                }
            }
        }
    }
}

struct LanguagePickerButton: View {
    @State private var showLanguagePicker = false
    
    var body: some View {
        ImpostorButton(systemImageName: "globe") {
            AudioManager.shared.playSoundEffect(named: "buttonPress")
            showLanguagePicker = true
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePicker()
        }
    }
}

#Preview {
    LanguagePicker()
}