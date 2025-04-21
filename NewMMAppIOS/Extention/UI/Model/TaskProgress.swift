import SwiftUI

struct TaskProgress: Identifiable {
    let id = UUID()
    var progress: Double
    var color: Color
    var name: String
    var value: Double
} 