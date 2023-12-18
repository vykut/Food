import Foundation
import ComposableArchitecture
import TabBar

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var tabBar: TabBar.State = .init()
    }

    @CasePathable
    enum Action {
        case tabBar(TabBar.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tabBar, action: \.tabBar) {
            TabBar()
        }
        Reduce { state, action in
            switch action {
                case .tabBar:
                    return .none
            }
        }
    }
}
