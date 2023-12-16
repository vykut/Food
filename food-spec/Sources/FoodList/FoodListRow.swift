import SwiftUI
import Shared

struct FoodListRow: View {
    let food: Food

    var body: some View {
        LabeledListRow(
            title: food.name.capitalized,
            footnote: food.nutritionalSummary
        )
    }
}

#Preview {
    List {
        FoodListRow(
            food: .preview
        )
    }
}
