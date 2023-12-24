import Foundation
import ComposableArchitecture
import Ads
import Billboard

@Reducer
struct BillboardReducer {
    typealias State = FoodList.State
    typealias Action = FoodList.Action

    @Dependency(\.billboardClient) private var billboardClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
                    return .run { [billboardClient] send in
                        do {
                            let stream = try await billboardClient.getRandomBanners()
                            for try await ad in stream {
                                await send(.billboard(.showBanner(ad)), animation: .default)
                            }
                        } catch {
                            dump(error)
                        }
                    }

                case .billboard(let billboard):
                    return reduce(state: &state, action: billboard)

                default:
                    return .none
            }
        }
    }

    private func reduce(state: inout FoodList.State, action: FoodList.Action.Billboard) -> EffectOf<Self> {
        switch action {
            case .showBanner(let banner):
                state.billboard.banner = banner
                return .none
        }
    }
}
