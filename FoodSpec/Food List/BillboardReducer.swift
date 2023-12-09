//
//  BillboardReducer.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 09/12/2023.
//

import Foundation
import ComposableArchitecture
import Billboard

@Reducer
struct BillboardReducer {
    typealias State = FoodListReducer.State
    typealias Action = FoodListReducer.Action

    @Dependency(\.billboardClient) private var billboardClient

    func reduce(into state: inout FoodListReducer.State, action: FoodListReducer.Action) -> Effect<FoodListReducer.Action> {
        switch action {
            case .onAppear:
                return .run { send in
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

    private func reduce(into state: inout FoodListReducer.State, action: FoodListReducer.Action.Billboard) -> Effect<FoodListReducer.Action> {
        switch action {
            case .showBanner(let banner):
                state.billboard.banner = banner
                return .none
        }
    }
}

extension FoodListReducer.State {
    struct Billboard: Equatable {
        var banner: BillboardAd?
    }
}

extension FoodListReducer.Action {
    @CasePathable
    enum Billboard {
        case showBanner(BillboardAd?)
    }
}
