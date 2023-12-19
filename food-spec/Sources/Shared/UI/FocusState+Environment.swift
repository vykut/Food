import SwiftUI

fileprivate enum FocusKey: EnvironmentKey {
    static var defaultValue: FocusState<String?>.Binding = FocusState<String?>().projectedValue
}

public extension EnvironmentValues {
    var focusState: FocusState<String?>.Binding {
        get { self[FocusKey.self] }
        set { self[FocusKey.self] = newValue }
    }
}
