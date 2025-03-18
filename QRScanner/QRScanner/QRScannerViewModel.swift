//
//  CSVExporter.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 12/03/2025.
//

import SwiftUI
import AVFoundation
import CoreLocation

class QRScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {
    @Published var scannedCode: String?
    @Published var isScanning = false
    @Published var showAlert = false
    @Published var capturedImage: UIImage?
    @Published var lastScanTimestamp: Date?
    @Published var currentLocation: CLLocationCoordinate2D?
    
    var captureSession: AVCaptureSession?
    private let locationManager = CLLocationManager()
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var pendingCode: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // Location manager setup
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    
    // Camera setup
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              let captureSession = captureSession,
              captureSession.canAddInput(videoInput) else {
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            
            // Setup for image capture - create once and keep it
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
        }
    }
    
    // Control scanning
        func startScanning() {
            if captureSession == nil {
                setupCaptureSession()
            }
            
            if let captureSession = captureSession, !captureSession.isRunning {
                // Start scanning on a background thread to avoid UI freezing
                DispatchQueue.global(qos: .background).async {
                    captureSession.startRunning()
                    
                    // Update the isScanning state on main thread
                    DispatchQueue.main.async {
                        self.isScanning = true
                    }
                }
                
                locationManager.startUpdatingLocation()
            }
        }
        
        func stopScanning() {
            if let captureSession = captureSession, captureSession.isRunning {
                // Stop scanning on a background thread
                DispatchQueue.global(qos: .background).async {
                    captureSession.stopRunning()
                    
                    // Update the isScanning state on main thread
                    DispatchQueue.main.async {
                        self.isScanning = false
                    }
                }
                
                locationManager.stopUpdatingLocation()
            }
        }
    
    // Handle QR code detection
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if we've scanned recently (within 3 seconds)
        if let lastScan = lastScanTimestamp, Date().timeIntervalSince(lastScan) < 3.0 {
            return
        }
        
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            
            // Store the code before capture
            pendingCode = stringValue
            lastScanTimestamp = Date()
            
            // Capture the current frame as an image
            captureCurrentFrame()
        }
    }
    
    // Capture image of QR code
    func captureCurrentFrame() {
        guard let captureSession = captureSession,
              captureSession.isRunning,
              let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// Photo capture delegate extension
extension QRScannerViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData),
           let code = pendingCode {
            
            // Now that we have the image, update the UI and model
            self.capturedImage = image
            self.scannedCode = code
            
            // Show alert
            self.showAlert = true
            
            // Auto-hide the alert after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlert = false
            }
            
            // Clear pending code
            self.pendingCode = nil
        }
    }
}
