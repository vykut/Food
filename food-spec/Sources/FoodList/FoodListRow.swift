import SwiftUI
import Shared

struct FoodListRow: View {
    let food: Food

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(food.name.capitalized)
            Text(food.nutritionalSummary)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    FoodListRow(
        food: .preview
    )
    .padding()
}
