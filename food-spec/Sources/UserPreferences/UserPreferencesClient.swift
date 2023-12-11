import Foundation
@_implementationOnly import UserDefaults
import Dependencies
import DependenciesMacros
import Semaphore

@DependencyClient
public struct UserPreferencesClient {
    public var getPreferences: @Sendable () -> UserPreferences = { .init() }
    @DependencyEndpoint(method: "set")
    public var setPreferences: @Sendable (_ preferences: (inout UserPreferences) -> Void) async throws -> Void
    public var observeChanges: @Sendable () async -> AsyncStream<UserPreferences> = { .finished }
}

extension UserPreferencesClient: DependencyKey {
    public static var liveValue: UserPreferencesClient = {
        typealias Stream = AsyncStream<UserPreferences>
        @Dependency(\.userDefaults) var userDefaults
        @Dependency(\.uuid) var uuid
        let continuations = ActorIsolated<[UUID: Stream.Continuation]>([:])
        let semaphore = AsyncSemaphore(value: 1)

        @Sendable func getPreferences() -> UserPreferences {
            guard let data = userDefaults.data(key: userPreferencesKey),
                  let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else { return .init() }
            return preferences
        }

        return .init(
            getPreferences: getPreferences,
            setPreferences: { modify in
                try await semaphore.waitUnlessCancelled()
                defer { semaphore.signal() }
                var preferences = getPreferences()
                modify(&preferences)
                userDefaults.set(object: preferences, key: userPreferencesKey)
                for continuation in await continuations.value.values {
                    continuation.yield(preferences)
                }
            },
            observeChanges: {
                let id = uuid()
                let (stream, continuation) = Stream.makeStream()
                continuation.onTermination = { _ in
                    Task {
                        await continuations.withValue {
                            $0[id] = nil
                        }
                    }
                }
                await continuations.withValue { continuations in
                    continuations[id] = continuation
                }
                return stream
            }
        )
    }()

    public static var testValue: UserPreferencesClient = .init()
}

private let userPreferencesKey = "userPreferences"

extension DependencyValues {
    public var userPreferencesClient: UserPreferencesClient {
        get { self[UserPreferencesClient.self] }
        set { self[UserPreferencesClient.self] = newValue }
    }
}
