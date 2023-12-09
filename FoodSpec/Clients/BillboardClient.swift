//
//  BillboardClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 08/12/2023.
//

import Foundation
import ComposableArchitecture
import Billboard

@DependencyClient
struct BillboardClient {
    var getRandomBanners: () async throws -> AsyncThrowingStream<BillboardAd?, Error>
}

extension BillboardClient: DependencyKey {
    static var liveValue: BillboardClient = .init(
        getRandomBanners: {
            @Dependency(\.continuousClock) var continuousClock
            let first = ActorIsolated(true)
            return .init {
                if await !first.value {
                    try await continuousClock.sleep(for: .seconds(30), tolerance: .zero)
                } else {
                    await first.setValue(false)
                }
                return try await BillboardViewModel.fetchRandomAd()
            }
        }
    )
}

extension DependencyValues {
    var billboardClient: BillboardClient {
        get { self[BillboardClient.self] }
        set { self[BillboardClient.self] = newValue }
    }
}
