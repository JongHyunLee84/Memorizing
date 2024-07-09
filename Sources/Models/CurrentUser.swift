import Dependencies
import Extensions
import Foundation

public struct CurrentUser: Codable, Equatable {
    public let id: String
    public var email: String
    public var nickname: String
    public var coin: Int
    public var signInPlatform: String
    
    public init(
        id: String,
        email: String,
        nickname: String,
        coin: Int,
        signInPlatform: Platform
    ) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.coin = coin
        self.signInPlatform = signInPlatform.rawValue
    }
    
    public init(
        id: String,
        email: String,
        nickname: String,
        coin: Int,
        signInPlatform: String
    ) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.coin = coin
        self.signInPlatform = signInPlatform
    }
    
    public enum Platform: String {
        case google
        case apple
        case kakao
        case unknown
    }
    
    public enum CodingKeys: CodingKey {
        case id
        case email
        case nickname
        case coin
        case signInPlatform
    }
}

public extension CurrentUser {
    static let mock = {
        return Self(
            id: UUID.zero.uuidString,
            email: "abc@gmail.com",
            nickname: "테스트계정",
            coin: 1000,
            signInPlatform: .google
        )
    }()
}
