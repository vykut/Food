import SwiftUI

public struct OnFirstAppear: ViewModifier {
    private let action: () -> Void

    @State private var hasAppeared = false

    public init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                defer { hasAppeared = true }
                action()
            }
    }
}

public extension View {
    /// runs the `action` closure only the **first time** the view appears
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        return modifier(OnFirstAppear(action))
    }
}
