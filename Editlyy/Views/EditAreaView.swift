//
//  EditAreaView.swift
//  Editlyy
//
//  Created by Mücahit Kökdemir NTT on 27.01.2025.
//

import SwiftUI

struct EditAreaView: View {
    let type: ToolType
    
    var body: some View {
        Group {
            switch type {
            case .compressImage:
                CompressImageView()
            case .compressVideo:
                CompressImageView()
            }
        }
        .navigationTitle(title(for: type))
    }
    
    private func title(for type: ToolType) -> String {
        switch type {
        case .compressImage: return "Compress Image"
        case .compressVideo: return "Compress Video"
        }
    }
}

#Preview {
    EditAreaView(type: .compressImage)
}

