//
//  DocumentPickerExporter.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 18/03/2025.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPickerExporter: UIViewControllerRepresentable {
    var directoryURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create document picker for exporting the entire directory
        let picker = UIDocumentPickerViewController(forExporting: [directoryURL])
        picker.delegate = context.coordinator
        
        // Optional: Allow the user to select multiple directories/locations
        picker.allowsMultipleSelection = false
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerExporter
        
        init(_ parent: DocumentPickerExporter) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Document picker selected: \(urls)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker cancelled")
            parent.presentationMode.wrappedValue.dismiss()
            
            // Clean up temp directory on cancel
            do {
                try FileManager.default.removeItem(at: parent.directoryURL)
            } catch {
                print("Error removing temp directory: \(error)")
            }
        }
    }
}
