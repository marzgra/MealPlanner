import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var unit: String // np. "g", "ml", "szt.", "łyżeczka"
}
