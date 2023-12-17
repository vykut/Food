import SwiftUI

public struct ListButton<Content: View>: View {
    @Environment(\.isEnabled) var isEnabled

    let action: () -> Void
    let label: () -> Content

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack {
                label()
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(isEnabled ? .primary : .secondary)
    }
}

public extension ListButton where Content == Text {
    init(_ text: String, action: @escaping () -> Void) {
        self.init(
            action: action,
            label: {
                Text(text)
            }
        )
    }
}

#Preview {
    List {
        ListButton("List Button") {
            // do something
        }
    }
}
