import SwiftUI

public struct SpinnerListRow: View {
    let label: String

    public init(label: String = "Searching...") {
        self.label = label
    }

    public var body: some View {
        HStack {
            Spacer()
            ProgressView(label)
                .id(UUID())
            Spacer()
        }
    }
}

#Preview {
    SpinnerListRow()
}
