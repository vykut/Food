import Foundation
import ComposableArchitecture
import Shared

@Reducer
public struct QuantityPicker {
    @ObservableState
    public struct State: Hashable {
        let id: Food.ID
        public var quantity: Quantity
        public var options: [Quantity.Unit]

        public init(
            id: Food.ID,
            quantity: Quantity = .grams(100),
            options: [Quantity.Unit] = [.grams, .pounds, .ounces, .cups, .tablespoons, .teaspoons]
        ) {
            self.id = id
            self.quantity = quantity
            self.options = options
        }
    }

    @CasePathable
    public enum Action {
        case updateValue(Double)
        case updateUnit(Quantity.Unit)
        case incrementButtonTapped
        case decrementButtonTapped
    }

    public init() { }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            case .updateValue(let value):
                guard value > 0 && value <= 1000 else { return .none }
                state.quantity.value = value
                return .none

            case .updateUnit(let unit):
                guard unit != state.quantity.unit else { return .none }
                state.quantity = Quantity(
                    value: unit == .grams ? 100 : 1,
                    unit: unit
                )
                return .none

            case .incrementButtonTapped:
                let stride = incrementStride(for: state.quantity.unit)
                state.quantity.value = min(state.quantity.value + stride, 1000)
                return .none

            case .decrementButtonTapped:
                let stride = incrementStride(for: state.quantity.unit)
                state.quantity.value = max(state.quantity.value - stride, stride)
                return .none
        }
    }

    private func incrementStride(for unit: Quantity.Unit) -> Double {
        switch unit {
            case .grams: 10
            case .pounds: 0.5
            case .ounces: 0.5
            case .cups: 0.25
            case .tablespoons: 0.5
            case .teaspoons: 0.5
            default: 1
        }
    }
}
