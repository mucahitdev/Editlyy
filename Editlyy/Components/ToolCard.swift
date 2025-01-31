//
//  ToolCard.swift
//  Editlyy
//
//  Created by Mücahit Kökdemir NTT on 27.01.2025.
//

import SwiftUI

struct ToolCard: View {
    let tool: Tool
    @State private var navigateToEdit: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header with icon and title
            HStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                Text(tool.name)
                    .font(.headline)
                    .lineLimit(2)
            }
            
            // Description
            Text(tool.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Spacer()
            // Action button
            PrimaryButton(title: "Select", icon: "play.fill") {
                navigateToEdit = true // Geçişi tetikleme
            }
        }
        .padding()
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .navigationDestination(isPresented: $navigateToEdit) {
            EditAreaView(type: tool.type)
        }
    }
}

#Preview {
    ToolCard(tool: Tool(name: "as", icon: "kes", description: "kl", type: .compressImage))
}
