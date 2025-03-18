//
//  QRCodeDetailView.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 14/03/2025.
//

import SwiftUI
import MapKit

struct QRCodeDetailView: View {
    let qrCode: QRCodeScan
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // QR Code Content
                Group {
                    Text("QR Code Content:")
                        .font(.headline)
                    Text(qrCode.content ?? "No content")
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Timestamp
                Group {
                    Text("Scanned on:")
                        .font(.headline)
                    if let timestamp = qrCode.timestamp {
                        Text("\(timestamp, formatter: dateFormatter)")
                            .font(.body)
                    } else {
                        Text("Unknown time")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
                
                // Location
                if qrCode.latitude != 0 && qrCode.longitude != 0 {
                    Group {
                        Text("Location:")
                            .font(.headline)
                        
                        VStack(alignment: .leading) {
                            Text("Latitude: \(qrCode.latitude, specifier: "%.6f")")
                            Text("Longitude: \(qrCode.longitude, specifier: "%.6f")")
                        }
                        
                        // Updated Map code for iOS 17+
                        let coordinate = CLLocationCoordinate2D(
                            latitude: qrCode.latitude,
                            longitude: qrCode.longitude
                        )
                        
                        Map {
                            Marker("QR Scan Location", coordinate: coordinate)
                                .tint(.red)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                    }
                }
                
                // QR Code Image
                if let imageData = qrCode.imageData, let uiImage = UIImage(data: imageData) {
                    Group {
                        Text("QR Code Image:")
                            .font(.headline)
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("QR Code Details")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }
}
