import FirebaseAuth
import Models

extension CurrentUser {
    init(user: UserInfo) {
        self.init(
            id: user.uid,
            email: user.email ?? "No Email",
            nickname: user.displayName ?? "No Name",
            coin: 1000,
            signInPlatform: .unknown
        )
    }
    
    init(user: UserInfo, platform: Platform) {
        self.init(
            id: user.uid,
            email: user.email ?? "No Email",
            nickname: user.displayName ?? "No Name",
            coin: 1000,
            signInPlatform: platform
        )
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decodeIfPresent(String.self, forKey: .id) ?? "NO ID",
            email: try container.decodeIfPresent(String.self, forKey: .email) ?? "No Email",
            nickname: try container.decodeIfPresent(String.self, forKey: .nickname) ?? "No Nickname",
            coin: try container.decodeIfPresent(Int.self, forKey: .coin) ?? 0,
            signInPlatform: try container.decodeIfPresent(String.self, forKey: .signInPlatform) ?? "unkwown"
        )
    }
}
