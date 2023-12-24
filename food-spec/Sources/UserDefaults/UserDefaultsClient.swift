import Foundation
import Dependencies
import DependenciesMacros
import Shared

@DependencyClient
public struct UserDefaultsClient: Sendable {
    public var bool: @Sendable (_ key: String) -> Bool = { _ in false }
    public var string: @Sendable (_ key: String) -> String?
    public var data: @Sendable (_ key: String) -> Data?
    public var double: @Sendable (_ key: String) -> Double = { _ in 0 }
    public var integer: @Sendable (_ key: String) -> Int = { _ in 0 }
    public var remove: @Sendable (_ key: String) -> Void
    public var set: @Sendable (_ object: any Codable, _ key: String) -> Void

    public mutating func override(data: Data, forKey key: String) {
        self.data = { @Sendable [self] in $0 == key ? data : self.data($0) }
    }
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: Self = {
        let defaults = { @Sendable in UserDefaults(suiteName: "group.foodspec")! }
        return Self(
            bool: { defaults().bool(forKey: $0) },
            string: { defaults().string(forKey: $0) },
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

    public static var testValue: UserDefaultsClient = .init()
}

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
