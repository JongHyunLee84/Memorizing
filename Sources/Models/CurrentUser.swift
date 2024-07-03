import Dependencies
import Foundation

public struct CurrentUser: Codable {
    public let id: String
    public let email: String
    public let nickname: String
    public let coin: Int
    public let signInPlatform: String
    
    public init(id: String, email: String, nickname: String, coin: Int, signInPlatform: Platform) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.coin = coin
        self.signInPlatform = signInPlatform.rawValue
    }
    
    public enum Platform: String {
        case google
        case apple
        case kakao
        case unknown
    }
}

public extension CurrentUser {
    static let mock = {
        @Dependency(\.uuid) var uuid
        return Self(
            id: uuid().uuidString,
            email: "abc@gmail.com",
            nickname: "테스트계정",
            coin: 1000,
            signInPlatform: .google
        )
    }()
}
