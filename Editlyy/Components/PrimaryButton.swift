import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "Convert to GIF", icon: "arrow.right") {}
            .padding()
        
        PrimaryButton(title: "Save", icon: "square.and.arrow.down") {}
            .padding()
    }
} 