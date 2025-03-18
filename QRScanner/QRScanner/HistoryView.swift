//
//  HistoryView.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 12/03/2025.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var dataController: DataController
    @FetchRequest(
        entity: QRCodeScan.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \QRCodeScan.timestamp, ascending: false)
        ]
    ) private var qrCodes: FetchedResults<QRCodeScan>
    
    // Explicitly managed state variables for confirmation dialog
    @State private var showingClearConfirmation = false
    @State private var exportDirectoryURL: URL?
    @State private var showingExportSheet = false
    @State private var showExportError = false
    
    var body: some View {
        VStack {
            if qrCodes.isEmpty {
                Text("No scans yet")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(qrCodes, id: \.id) { qrCode in
                        NavigationLink(destination: QRCodeDetailView(qrCode: qrCode)) {
                            VStack(alignment: .leading) {
                                Text(qrCode.content ?? "No content")
                                    .font(.headline)
                                    .lineLimit(1)
                                if let timestamp = qrCode.timestamp {
                                    Text(timestamp, formatter: dateFormatter)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Unknown time")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            HStack {
                Button {
                    print("Export button tapped")
                    exportToCSV()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export All Data")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .opacity(qrCodes.isEmpty ? 0.5 : 1)
                .disabled(qrCodes.isEmpty)
                
                Button {
                    print("Clear history button tapped")
                    showingClearConfirmation = true
                    print("showingClearConfirmation set to \(showingClearConfirmation)")
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear History")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .opacity(qrCodes.isEmpty ? 0.5 : 1)
                .disabled(qrCodes.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Scan History")
        // Alert specifically for clear history confirmation
        .alert("Clear History", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {
                print("Cancel tapped")
            }
            Button("Clear", role: .destructive) {
                print("Clear tapped, calling clearAllHistory()")
                clearAllHistory()
            }
        } message: {
            Text("Are you sure you want to clear all scan history?")
        }
        // Sheet for exporting
        .sheet(isPresented: $showingExportSheet) {
            if let directoryURL = exportDirectoryURL {
                DocumentPickerExporter(directoryURL: directoryURL)
            }
        }
        // Alert for export errors
        .alert("Export Error", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(dataController.exportError ?? "Unknown error occurred")
        }
        // Handler for export success
        .onChange(of: dataController.exportSuccess) { _, newValue in
            if newValue {
                // Find the most recent export directory
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    do {
                        let contents = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                        let exportDirs = contents.filter { $0.lastPathComponent.starts(with: "qr_export_") }
                        if let latestExport = exportDirs.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }).first {
                            exportDirectoryURL = latestExport
                            showingExportSheet = true
                            // Reset the success flag
                            dataController.exportSuccess = false
                        }
                    } catch {
                        print("Error finding export directory: \(error)")
                    }
                }
            }
        }
        .onAppear {
            print("HistoryView appeared - QR code count: \(qrCodes.count)")
        }
    }
    
    private func clearAllHistory() {
        print("Clearing all history...")
        
        // Show current count
        let fetchRequest: NSFetchRequest<QRCodeScan> = QRCodeScan.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            print("Current record count: \(count)")
        } catch {
            print("Error counting records: \(error)")
        }
        
        // Manually delete all QRCodeScan objects
        do {
            let allQRCodes = try context.fetch(fetchRequest)
            print("Fetched \(allQRCodes.count) records for deletion")
            
            // Delete each record
            for qrCode in allQRCodes {
                context.delete(qrCode)
            }
            
            // Save context
            try context.save()
            print("Records deleted and context saved")
        } catch {
            print("Error during deletion: \(error)")
        }
        
        // Refresh the view
        DispatchQueue.main.async {
            // Force a UI update by triggering objectWillChange
            self.dataController.objectWillChange.send()
        }
    }
    
    private func exportToCSV() {
        dataController.exportToCSV()
        
        if dataController.exportError != nil {
            showExportError = true
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }
}
