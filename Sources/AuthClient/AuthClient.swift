import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct AuthClient {
    public var signOut: () async throws -> Void
    public var loginStateListener: () -> AsyncStream<CurrentUser?> = { .finished }
    public var changeNickname: (_ nickname: String) async throws -> Void
    public var deleteUser: () async throws -> Void
    public var googleSignIn: () async throws -> CurrentUser
    public var kakaoSignIn: () async throws -> CurrentUser
    public var appleSignIn: () async throws -> CurrentUser
    public var appleDeleteUser: () async throws -> Void
    public var getUserInfo: () async throws -> CurrentUser
    public var incrementUserCoin: (_ point: Int) async throws -> Void
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
