//
//  ContentView.swift
//  CloudSyncApp
//
//  Placeholder view (app is menu bar only)
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "cloud.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("CloudSync is running in the menu bar")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
