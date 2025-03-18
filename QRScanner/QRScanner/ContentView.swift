//
//  ContentView.swift
//  QRScanner
//
//  Created by Andrew Clarkson on 12/03/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            QRScannerView()
                .navigationTitle("QR Scanner")
                .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataController())
    }
}
