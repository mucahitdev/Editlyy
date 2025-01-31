//
//  ContentView.swift
//  Editlyy
//
//  Created by Mücahit Kökdemir NTT on 27.01.2025.
//

import SwiftUI

struct ContentView: View {
    // Grid layout configuration
    private let gridItems = [
        GridItem(.adaptive(minimum: 160, maximum: 320), spacing: 16)
    ]
    
    // Sample tools - later we can move this to ViewModel
    @State private var tools: [Tool] = [
        Tool(
            name: "Compress Image",
            icon: "arrow.down.circle.fill",
            description: "Reduce the size of your images",
            type: .compressImage
        ),
        Tool(
            name: "Compress Video",
            icon: "arrow.down.circle.fill",
            description: "Reduce the size of your videos",
            type: .compressVideo
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16) {
                    ForEach(tools) { tool in
                        ToolCard(tool: tool)
                    }
                }
                .padding()
            }
            .navigationTitle("Tools")

        }
    }
}

#Preview {
    ContentView()
}
