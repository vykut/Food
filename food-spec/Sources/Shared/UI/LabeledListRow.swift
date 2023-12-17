import SwiftUI

public struct LabeledListRow: View {
    let title: String
    let footnote: String?

    public init(title: String, footnote: String? = nil) {
        self.title = title
        self.footnote = footnote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            if let footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        LabeledListRow(
            title: Food.preview.name
        )
        LabeledListRow(
            title: Food.preview.name,
            footnote: Food.preview.nutritionalSummary
        )
    }
}
