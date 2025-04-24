import SwiftUI

struct TaskProgress: Identifiable, Equatable {
    let id = UUID()
    var progress: Double
    var color: Color
    var name: String
    var value: Double
    
    static func == (lhs: TaskProgress, rhs: TaskProgress) -> Bool {
        lhs.id == rhs.id &&
        lhs.progress == rhs.progress &&
        lhs.name == rhs.name &&
        lhs.value == rhs.value
        // Примечание: Color не сравниваем, так как оно может не соответствовать Equatable
    }
} 