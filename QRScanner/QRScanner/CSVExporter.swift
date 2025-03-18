//
//  CSVExporter.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 18/03/2025.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct CSVExporter: UIViewControllerRepresentable {
    var fileURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create the activity view controller with the CSV file
        let controller = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        // Configure the completion handler
        controller.completionWithItemsHandler = { _, completed, _, error in
            if let error = error {
                print("Error sharing file: \(error.localizedDescription)")
            }
            
            // Dismiss the sheet regardless of completion status
            self.presentationMode.wrappedValue.dismiss()
        }
        
        // Specify the UTType for CSV files
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .postToFacebook,
            .postToTwitter
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update
    }
}
