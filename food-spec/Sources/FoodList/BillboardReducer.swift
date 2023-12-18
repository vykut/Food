import Foundation
import ComposableArchitecture
import Ads

@Reducer
struct BillboardReducer {
    typealias State = FoodList.State
    typealias Action = FoodList.Action

    @Dependency(\.billboardClient) private var billboardClient

    func reduce(into state: inout FoodList.State, action: FoodList.Action) -> Effect<FoodList.Action> {
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

    private func reduce(into state: inout FoodList.State, action: FoodList.Action.Billboard) -> Effect<FoodList.Action> {
        switch action {
            case .showBanner(let banner):
                state.billboard.banner = banner
                return .none
        }
    }
}

extension FoodList.State {
    public struct Billboard: Equatable {
        var banner: BillboardAd?
    }
}

extension FoodList.Action {
    @CasePathable
    public enum Billboard {
        case showBanner(BillboardAd?)
    }
}
