import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct URLClient {
    public var getIntroduceURL: @Sendable () async -> URL?
    public var getPrivacyPolicyURL: @Sendable () async -> URL?
    public var getCSURL: () async -> URL?
}

extension DependencyValues {
    public var urlClient: URLClient {
        get { self[URLClient.self] }
        set { self[URLClient.self] = newValue }
    }
}

extension URLClient: TestDependencyKey {
    public static var testValue = Self(
            getIntroduceURL: { mockURL },
            getPrivacyPolicyURL: { mockURL },
            getCSURL: { mockURL }
    )
    
    public static var previewValue = testValue
}

public let mockURL = URL(string: "https://www.google.com")!

