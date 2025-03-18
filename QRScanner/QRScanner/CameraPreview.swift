//
//  CameraPreview.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 14/03/2025.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    var scannerViewModel: QRScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if scannerViewModel.captureSession == nil {
            scannerViewModel.setupCaptureSession()
        }
        
        if let captureSession = scannerViewModel.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            scannerViewModel.previewLayer = previewLayer
            
            // Start scanning after view is created
            // but don't modify state properties directly in the view creation
            if !captureSession.isRunning {
                // We'll start the session from QRScannerView's onAppear
                // This avoids publishing changes during view updates
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
