import Foundation
import ComposableArchitecture
import Ads

@Reducer
struct BillboardReducer {
    typealias State = FoodListFeature.State
    typealias Action = FoodListFeature.Action

    @Dependency(\.billboardClient) private var billboardClient

    func reduce(into state: inout FoodListFeature.State, action: FoodListFeature.Action) -> Effect<FoodListFeature.Action> {
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
                return reduce(into: &state, action: billboard)

            default:
                return .none
        }
    }

    private func reduce(into state: inout FoodListFeature.State, action: FoodListFeature.Action.Billboard) -> Effect<FoodListFeature.Action> {
        switch action {
            case .showBanner(let banner):
                state.billboard.banner = banner
                return .none
        }
    }
}

extension FoodListFeature.State {
    public struct Billboard: Equatable {
        var banner: BillboardAd?
    }
}

extension FoodListFeature.Action {
    @CasePathable
    public enum Billboard {
        case showBanner(BillboardAd?)
    }
}
