import Foundation
import ComposableArchitecture
import TabBar

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var tabBar: TabBarFeature.State = .init()
    }

    @CasePathable
    enum Action {
        case tabBar(TabBarFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tabBar, action: \.tabBar) {
            TabBarFeature()
        }
        Reduce { state, action in
            switch action {
                case .tabBar:
                    return .none
            }
        }
    }
}
