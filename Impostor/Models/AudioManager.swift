//
//  AudioManager.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import AVFoundation
import AudioToolbox

class AudioManager {
    static let shared = AudioManager()
    private var backgroundPlayer: AVAudioPlayer?
    private var soundEffectIDs: [String: SystemSoundID] = [:]

    // Play background music
    func playBackgroundSound(named soundFileName: String, repeating: Bool = true) {
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else { return }

        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = repeating ? -1 : 1
            backgroundPlayer?.play()
        } catch {
            print("Error playing background sound: \(error)")
        }
    }

    // Stop background music with fade out
    func stopBackgroundSound(fadeDuration: TimeInterval = 1.0) {
        guard let player = backgroundPlayer, player.isPlaying else { return }

        // Fade out effect
        let fadeSteps = Int(fadeDuration / 0.05) // Update every 0.05 seconds
        let fadeAmount = player.volume / Float(fadeSteps)

        for step in 0..<fadeSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.05) {
                player.volume -= fadeAmount
                if step == fadeSteps - 1 {
                    player.stop()
                    player.volume = 1.0 // Reset volume for next play
                }
            }
        }
    }

    // Play a quick sound effect
    func playSoundEffect(named soundEffectName: String) {
        if let soundID = soundEffectIDs[soundEffectName] {
            // Play cached sound effect
            AudioServicesPlaySystemSound(soundID)
        } else if let url = Bundle.main.url(forResource: soundEffectName, withExtension: "mp3") {
            // Create and cache the sound effect
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            soundEffectIDs[soundEffectName] = soundID
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
