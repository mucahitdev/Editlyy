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
        
        Text("Hello, World \(type)")
    }
}

#Preview {
    EditAreaView(type: .videoToGif)
}
