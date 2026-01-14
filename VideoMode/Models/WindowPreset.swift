import Foundation

struct WindowPreset: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var width: Int
    var height: Int
    var x: Int
    var y: Int

    init(id: UUID = UUID(), name: String, width: Int, height: Int, x: Int, y: Int) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.x = x
        self.y = y
    }

    var sizeDescription: String {
        "\(width)x\(height)"
    }

    var positionDescription: String {
        "(\(x), \(y))"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
