//
//  UserDefaultsClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 04/12/2023.
//

import Foundation
import ComposableArchitecture

public struct UserDefaultsClient {
    public var bool: @Sendable (_ key: String) -> Bool
    public var data: @Sendable (_ key: String) -> Data?
    public var double: @Sendable (_ key: String) -> Double
    public var integer: @Sendable (_ key: String) -> Int
    public var object: @Sendable (_ key: String) -> Any?
    public var remove: @Sendable (_ key: String) -> Void
    public var set: @Sendable (_ object: any Codable, _ key: String) -> Void

    func object<T: Codable>(key: String) -> T? {
        guard let data = self.object(key) as? Data else { return nil }
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
            object: { defaults().object(forKey: $0) },
            remove: { defaults().removeObject(forKey: $0) },
            set: { value, key in
                let encoder = JSONEncoder()
                guard let data = try? encoder.encode(value) else { return }
                defaults().set(data, forKey: key)
            }
        )
    }()
}

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
