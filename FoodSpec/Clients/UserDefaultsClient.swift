//
//  UserDefaultsClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 04/12/2023.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

public struct UserDefaultsClient {
    public var bool: @Sendable (_ key: String) -> Bool
    public var data: @Sendable (_ key: String) -> Data?
    public var double: @Sendable (_ key: String) -> Double
    public var integer: @Sendable (_ key: String) -> Int
    public var remove: @Sendable (_ key: String) -> Void
    public var set: @Sendable (_ object: any Codable, _ key: String) -> Void

    func object<T: Codable>(key: String) -> T? {
        guard let data = self.data(key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

    var recentSearchesSortingStrategy: Food.SortingStrategy? {
        get { object(key: recentSearchesSortingStrategyKey) }
        nonmutating set {
            if let newValue {
                set(newValue, recentSearchesSortingStrategyKey)
            } else {
                remove(recentSearchesSortingStrategyKey)
            }
        }
    }

    var recentSearchesSortingOrder: SortOrder? {
        get { object(key: recentSearchesSortingOrderKey) }
        nonmutating set {
            if let newValue {
                set(newValue, recentSearchesSortingOrderKey)
            } else {
                remove(recentSearchesSortingOrderKey)
            }
        }
    }

    mutating func override(data: Data, forKey key: String) {
        self.data = { [self] in $0 == key ? data : self.data($0) }
    }
}

private let recentSearchesSortingStrategyKey = "recentSearchesSortingStrategyKey"
private let recentSearchesSortingOrderKey = "recentSearchesSortingOrderKey"

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: Self = {
        let defaults = { UserDefaults(suiteName: "group.foodspec")! }
        return Self(
            bool: { defaults().bool(forKey: $0) },
            data: { defaults().data(forKey: $0) },
            double: { defaults().double(forKey: $0) },
            integer: { defaults().integer(forKey: $0) },
            remove: { defaults().removeObject(forKey: $0) },
            set: { value, key in
                let encoder = JSONEncoder()
                guard let data = try? encoder.encode(value) else { return }
                defaults().set(data, forKey: key)
            }
        )
    }()

    static public var testValue: UserDefaultsClient = .init(
        bool: unimplemented("\(Self.self).bool", placeholder: false),
        data: unimplemented("\(Self.self).data", placeholder: nil),
        double: unimplemented("\(Self.self).double", placeholder: .zero),
        integer: unimplemented("\(Self.self).integer", placeholder: .zero),
        remove: unimplemented("\(Self.self).remove"),
        set: unimplemented("\(Self.self).set")
    )
}

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
