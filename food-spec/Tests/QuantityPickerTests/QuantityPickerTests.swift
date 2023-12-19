import Foundation
import XCTest
import Shared
import ComposableArchitecture
@testable import QuantityPicker

@MainActor
final class QuantityPickerTests: XCTestCase {
    func testFullFlow() async throws {
        let store = TestStore(
            initialState: QuantityPicker.State(id: nil),
            reducer: {
                QuantityPicker()
            }
        )

        await store.send(.updateValue(300)) {
            $0.quantity.value = 300
        }
        await store.send(.updateValue(0))
        await store.send(.updateValue(1000)) {
            $0.quantity.value = 1000
        }
        await store.send(.updateValue(1000.003))

        await store.send(.updateUnit(.grams))
        await store.send(.updateUnit(.ounces)) {
            $0.quantity = .init(value: 1, unit: .ounces)
        }
        await store.send(.updateUnit(.grams)) {
            $0.quantity = .init(value: 100, unit: .grams)
        }

        await store.send(.incrementButtonTapped) {
            $0.quantity.value = 110
        }
        await store.send(.updateValue(1000)) {
            $0.quantity.value = 1000
        }
        await store.send(.incrementButtonTapped)
        await store.send(.updateValue(1)) {
            $0.quantity.value = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.quantity.value = 10
        }
        await store.send(.updateUnit(.pounds)) {
            $0.quantity = .init(value: 1, unit: .pounds)
        }
        await store.send(.incrementButtonTapped) {
            $0.quantity.value = 1.5
        }
        await store.send(.updateUnit(.ounces)) {
            $0.quantity = .init(value: 1, unit: .ounces)
        }
        await store.send(.incrementButtonTapped) {
            $0.quantity.value = 1.5
        }
        await store.send(.updateUnit(.cups)) {
            $0.quantity = .init(value: 1, unit: .cups)
        }
        await store.send(.incrementButtonTapped) {
            $0.quantity.value = 1.25
        }
        await store.send(.updateUnit(.tablespoons)) {
            $0.quantity = .init(value: 1, unit: .tablespoons)
        }
        await store.send(.incrementButtonTapped) {
            $0.quantity.value = 1.5
        }
        await store.send(.updateUnit(.teaspoons)) {
            $0.quantity = .init(value: 1, unit: .teaspoons)
        }
        await store.send(.incrementButtonTapped) {
            $0.quantity.value = 1.5
        }
    }
}
