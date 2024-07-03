import FirebaseAuth
import Models

extension CurrentUser {
    public init(user: UserInfo) {
        self.init(
            id: user.uid,
            email: user.email ?? "No Email",
            nickname: user.displayName ?? "No Name",
            coin: 1000,
            signInPlatform: .unknown
        )
    }
}
