import Foundation
import XCTest
import ComposableArchitecture
@testable import TabBar

@MainActor
final class TabBarTests: XCTestCase {
    func testUpdateTab() async throws {
        let store = TestStore(
            initialState: TabBar.State(),
            reducer: {
                TabBar()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
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
