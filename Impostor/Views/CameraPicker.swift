//
//  CameraPicker.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-13.
//

import SwiftUI
import UIKit

// TODO: this is a workaround until SwiftUI can control the camera

struct CameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode

    // Required method to create the UIViewController instance
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraDevice = .front
        return picker
    }
    
    // Required method, but no updates happen
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // Method to make a coordinator which will act as the UIImagePickerControllerDelegate
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        // UIImagePickerControllerDelegate method
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image) // Call the callback with the selected image
            }
            
            parent.presentationMode.wrappedValue.dismiss() // Dismiss the UIImagePickerController
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() // Dismiss if the user cancels
        }
    }
}
