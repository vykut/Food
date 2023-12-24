import Foundation

public extension Meal {
    enum SortStrategy: String, Codable, Identifiable, Hashable, CaseIterable, Sendable {
        case name

        public var id: Self { self }
    }
}

public extension Meal {
    static var preview: Self {
        .init(
            name: "Preview",
            ingredients: [
                .preview
            ],
            servings: 2,
            instructions: "Some notes"
        )
    }
}
