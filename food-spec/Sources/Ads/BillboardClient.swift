import Foundation
import Dependencies
import DependenciesMacros
@_exported import Billboard

@DependencyClient
public struct BillboardClient {
    public var getRandomBanners: () async throws -> AsyncThrowingStream<BillboardAd?, Error>
}

extension BillboardClient: DependencyKey {
    public static var liveValue: BillboardClient = .init(
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

    public static var testValue: BillboardClient = .init()
}

extension DependencyValues {
    public var billboardClient: BillboardClient {
        get { self[BillboardClient.self] }
        set { self[BillboardClient.self] = newValue }
    }
}
