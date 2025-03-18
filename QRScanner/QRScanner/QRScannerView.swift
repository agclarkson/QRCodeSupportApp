//
//  QRScannerView.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 12/03/2025.
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject private var viewModel = QRScannerViewModel()
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var dataController: DataController
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CameraPreview(scannerViewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Scan a QR Code")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                    }) {
                        Text(viewModel.isScanning ? "Pause" : "Scan")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: HistoryView()) {
                        Text("History")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            if viewModel.showAlert {
                VStack {
                    Text("QR Code Scanned!")
                        .font(.headline)
                    Text(viewModel.scannedCode ?? "")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .onAppear {
                    // Save the scan to Core Data
                    if let content = viewModel.scannedCode {
                        dataController.saveQRCode(
                            content: content,
                            timestamp: Date(),
                            location: viewModel.currentLocation,
                            imageData: viewModel.capturedImage?.jpegData(compressionQuality: 0.7)
                        )
                    }
                }
            }
        }
        .onAppear {
            // Start scanning when view appears
            // This is the correct place to call this, not in CameraPreview
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}
