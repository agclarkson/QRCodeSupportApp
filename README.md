# QR Scanner App

A comprehensive QR code scanning iOS application built with SwiftUI and Core Data.

## Features

- **QR Code Scanning**: Scan QR codes using the device's camera
- **History Management**: View, manage, and clear your scan history
- **Location Tagging**: Automatically adds location data to scanned codes (when permitted)
- **Image Capture**: Captures and stores images of scanned QR codes
- **Detailed View**: View complete details for each scan including location on a map
- **Data Export**: Export your scan history with images as a package to share or save

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later
- Camera and Location permissions

## Installation

1. Clone or download this repository
2. Open `QRScanner.xcodeproj` in Xcode
3. Build and run the project on your device or simulator

## Usage

### Scanning QR Codes

1. Launch the app
2. Point your camera at a QR code
3. The app will automatically detect and scan the code
4. View the scanned content immediately on screen

### Managing Scan History

1. Tap the "History" button to view all previous scans
2. Tap on any scan to view complete details
3. Use the "Clear History" button to delete all scan records
4. Use the "Export All Data" button to export your scan history with images

### Exporting Data

When exporting data:
1. A folder is created with a CSV file containing all scan data
2. All QR code images are included as JPG files
3. Use the iOS document picker to save to Files, iCloud Drive, or share with other apps

## Project Structure

- **QRScannerApp.swift**: Main app entry point and environment setup
- **ContentView.swift**: Root view of the application
- **CameraPreview.swift**: UIViewRepresentable for camera preview
- **CSVExporter.swift**: Handles exporting scan data as CSV
- **DataController.swift**: Core Data management and persistence
- **DocumentPickerExporter.swift**: Document picker for sharing exported data
- **HistoryView.swift**: View for displaying scan history
- **LaunchScreen.storyboard**: App launch screen
- **QRCodeDetailView.swift**: Detailed view for individual scans
- **QRScanner.swift**: Core scanning functionality
- **QRScannerView.swift**: Camera view for scanning QR codes
- **QRScannerViewModel.swift**: Business logic for QR scanning

### Test Targets
- **QRScannerTests**: Unit tests for the application
- **QRScannerUITests**: UI tests for the application

## Permissions

The app requires the following permissions:
- **Camera**: For scanning QR codes
- **Location**: For tagging QR codes with location data
- **Photo Library**: For saving QR code images (when using export)

## Customization

### Modifying the UI

The app uses SwiftUI for its interface. Main views can be customized in:
- QRScannerView.swift (scanner interface)
- HistoryView.swift (history list)
- QRCodeDetailView.swift (detailed information)

### Data Storage

The app uses Core Data for data persistence. The model can be modified in:
- QRScanner.xcdatamodeld

## Troubleshooting

### Camera Not Working
- Ensure camera permissions are granted in Settings
- Check if the device has a working camera

### Location Not Showing
- Enable location permissions for the app in Settings
- Make sure location services are enabled on the device

### Export Issues
- Ensure the app has permissions to access Files
- Check available storage space on the device

## License

MIT License

Copyright (c) 2025 [Andrew Clarkson]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Acknowledgements

- [AVFoundation](https://developer.apple.com/documentation/avfoundation) for camera functionality
- [CoreLocation](https://developer.apple.com/documentation/corelocation) for location services
- [CoreData](https://developer.apple.com/documentation/coredata) for data persistence
- [SwiftUI](https://developer.apple.com/documentation/swiftui) for the user interface
- [MapKit](https://developer.apple.com/documentation/mapkit) for map integration
