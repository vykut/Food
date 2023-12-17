import Foundation
import XCTest
import ComposableArchitecture
@testable import TabBar

@MainActor
final class TabBarTests: XCTestCase {
    func testUpdateTab() async throws {
        let store = TestStore(
            initialState: TabBarFeature.State(),
            reducer: {
                TabBarFeature()
            }
        )
        await store.send(.updateTab(.foodSelection)) {
            $0.tab = .foodSelection
        }
        await store.send(.updateTab(.foodList)) {
            $0.tab = .foodList
        }
        await store.send(.updateTab(.mealList)) {
            $0.tab = .mealList
        }
    }
}
