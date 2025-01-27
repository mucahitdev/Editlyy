import Foundation

struct Tool: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let type: ToolType
}

enum ToolType {
    case videoToGif
    case trimVideo
}
