import Foundation

public enum AuthError: Error {
    case noClientID
    case noRootViewController
    case noToken
    case noUser
    case noKakaoInfo
    case noAccount
    case noAppleLoginResult
    case decode
}
