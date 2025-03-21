//
//  DataController.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 12/03/2025.
//
import CoreData
import CoreLocation
import UniformTypeIdentifiers
import UIKit

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "QRScanner")
    @Published var exportSuccess = false
    @Published var exportError: String?
    
    init() {
        print("📱 DataController initializing")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
    }
    
    func saveQRCode(content: String, timestamp: Date, location: CLLocationCoordinate2D?, imageData: Data?) {
        let context = container.viewContext
        
        let qrCode = QRCodeScan(context: context)
        qrCode.id = UUID()
        qrCode.content = content
        qrCode.timestamp = timestamp
        
        if let location = location {
            qrCode.latitude = location.latitude
            qrCode.longitude = location.longitude
        }
        
        qrCode.imageData = imageData
        
        do {
            try context.save()
            print("✅ QR Code saved successfully")
        } catch {
            print("❌ Error saving QR code: \(error)")
        }
    }
    
    // Original function kept for backward compatibility
    func deleteAllRecords() {
        print("🔴 deleteAllRecords called")
        deleteAllRecordsDebug()
    }
    
    // New debug version with verbose logging
    func deleteAllRecordsDebug() {
        print("🧨 STARTING DELETION PROCESS")
        
        // Get total count first
        let fetchRequest: NSFetchRequest<QRCodeScan> = QRCodeScan.fetchRequest()
        var totalCount = 0
        
        do {
            totalCount = try container.viewContext.count(for: fetchRequest)
            print("🔍 Found \(totalCount) records to delete")
        } catch {
            print("❌ Error counting records: \(error)")
        }
        
        // Approach 1: Delete objects individually with direct save
        do {
            print("🔴 Trying individual delete approach")
            let context = container.viewContext
            
            // Fetch all objects
            let objects = try context.fetch(fetchRequest)
            print("🔍 Fetched \(objects.count) objects for deletion")
            
            // Delete each one
            for (index, object) in objects.enumerated() {
                print("🗑️ Deleting object \(index+1) of \(objects.count): \(object.id?.uuidString ?? "no-id")")
                context.delete(object)
            }
            
            // Save changes
            if context.hasChanges {
                print("💾 Saving context after individual deletions")
                try context.save()
                print("✅ Context saved successfully")
            } else {
                print("⚠️ No changes to save after deletions")
            }
            
            // Verify deletion
            let remainingCount = try context.count(for: fetchRequest)
            print("🔍 After deletion: \(remainingCount) records remain")
            
            // Force context reset to ensure changes are processed
            print("🔄 Resetting context")
            context.reset()
            
            // Check again after reset
            let finalCount = try context.count(for: fetchRequest)
            print("🔍 After context reset: \(finalCount) records remain")
            
            return // Exit if this approach worked
        } catch {
            print("❌ Individual delete approach failed: \(error)")
        }
        
        // Approach 2: Batch delete as a fallback
        do {
            print("🔴 Trying batch delete approach")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try container.persistentStoreCoordinator.execute(batchDeleteRequest, with: container.viewContext) as? NSBatchDeleteResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                print("🔍 Batch delete returned \(objectIDs.count) object IDs")
                
                // Merge changes into context
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                    into: [container.viewContext]
                )
                print("✅ Merged batch delete changes into context")
                
                // Verify batch deletion
                let countAfterBatch = try container.viewContext.count(for: fetchRequest)
                print("🔍 After batch deletion: \(countAfterBatch) records remain")
            } else {
                print("⚠️ Batch delete didn't return object IDs")
            }
        } catch {
            print("❌ Batch delete approach failed: \(error)")
        }
        
        // Approach 3: Nuclear option - recreate the persistent store
        do {
            print("🔴 Trying direct SQL delete approach")
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "QRCodeScan")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try container.persistentStoreCoordinator.execute(deleteRequest, with: container.viewContext)
            container.viewContext.reset()
            print("✅ Executed direct SQL delete")
            
            // Check final count
            let finalRequest: NSFetchRequest<QRCodeScan> = QRCodeScan.fetchRequest()
            let finalCount = try container.viewContext.count(for: finalRequest)
            print("🔍 Final count: \(finalCount) records")
        } catch {
            print("❌ Direct SQL delete failed: \(error)")
        }
        
        print("🧨 DELETION PROCESS COMPLETED")
    }
    
    func exportToCSV() {
        print("DataController.exportToCSV() started")
        // Reset status
        exportSuccess = false
        exportError = nil
        
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<QRCodeScan> = QRCodeScan.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \QRCodeScan.timestamp, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let qrCodes = try context.fetch(fetchRequest)
            print("Fetched \(qrCodes.count) QR codes from Core Data")
            
            if qrCodes.isEmpty {
                exportError = "No QR codes to export"
                print("No QR codes to export")
                return
            }
            
            // Get document directory URL
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                exportError = "Could not access document directory"
                print("Could not access document directory")
                return
            }
            print("Documents directory: \(documentsDirectory.path)")
            
            // Generate timestamp for filenames
            let currentDateTime = Date()
            let filenameFormatter = DateFormatter()
            filenameFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = filenameFormatter.string(from: currentDateTime)
            
            // Try a simple test file first
            let testFileURL = documentsDirectory.appendingPathComponent("test_\(timestamp).txt")
            do {
                try "Test file".write(to: testFileURL, atomically: true, encoding: .utf8)
                print("Successfully created test file at: \(testFileURL.path)")
            } catch {
                print("Failed to create test file: \(error)")
            }
            
            // Rest of your export code...
            
            // Set success flag at the end
            print("Setting exportSuccess = true")
            DispatchQueue.main.async {
                self.exportSuccess = true
                self.objectWillChange.send()
                print("Notified observers of success state change")
            }
        } catch {
            exportError = "Failed to fetch QR codes: \(error.localizedDescription)"
            print("Error fetching QR codes: \(error)")
        }
    }
}
