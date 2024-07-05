import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct AuthClient {
    public var signOut: @Sendable () async throws -> Void
    public var loginStateListener: @Sendable () -> AsyncStream<CurrentUser?> = { .finished }
    public var changeNickname: @Sendable (_ nickname: String) async throws -> Void
    public var deleteUser: @Sendable () async throws -> Void
    public var googleSignIn: @Sendable () async throws -> CurrentUser
    public var kakaoSignIn: @Sendable () async throws -> CurrentUser
    public var appleSignIn: @Sendable () async throws -> CurrentUser
    public var appleDeleteUser: @Sendable () async throws -> Void
    public var getUserInfo: @Sendable () async throws -> CurrentUser
    public var incrementUserCoin: @Sendable (_ point: Int) async throws -> Void
}

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

extension AuthClient: TestDependencyKey {
    public static var testValue = Self(
        signOut: { },
        loginStateListener: { .finished },
        changeNickname: { _ in },
        deleteUser: { },
        googleSignIn: { .mock },
        kakaoSignIn: { .mock },
        appleSignIn: { .mock },
        appleDeleteUser: { },
        getUserInfo: { .mock },
        incrementUserCoin: { _ in }
    )
    
    public static var previewValue = testValue
}
