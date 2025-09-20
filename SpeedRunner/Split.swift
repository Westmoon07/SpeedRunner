import Foundation

struct Split: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var time: TimeInterval? = nil
}
