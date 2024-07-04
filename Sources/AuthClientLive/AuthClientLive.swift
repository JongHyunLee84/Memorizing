import AuthClient
import Dependencies
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKAuth
import KakaoSDKUser
import Models

extension AuthClient: DependencyKey {
    public static let liveValue = {
        let oauthManager = OAuthManager()
        return Self(
            signOut: {
                try Auth.auth().signOut()
            },
            loginStateListener: {
                AsyncStream<CurrentUser?> { continuation in
                    let handle = Auth.auth().addStateDidChangeListener { _, user in
                        if let user {
                            continuation.yield(
                                .init(user: user)
                            )
                        } else {
                            continuation.yield(nil)
                        }
                    }
                    continuation.onTermination = { _ in
                        Auth.auth().removeStateDidChangeListener(handle)
                    }
                }
            },
            changeNickname: { nickname in
                guard let currentUser = Auth.auth().currentUser else { throw AuthError.noUser }
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = nickname
                _ = try await (changeRequest.commitChanges(),
                               updateNickname(currentUser.uid, nickname))
            },
            deleteUser: {
                guard let user = Auth.auth().currentUser else { throw AuthError.noUser }
                _ = try await (user.delete(),
                               deleteUserInfo(user.uid))
            },
            googleSignIn: { @MainActor [presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController] in
                guard let presentingViewController else { throw AuthError.noRootViewController }
                guard let clientID = FirebaseApp.app()?.options.clientID else { throw  AuthError.noClientID }
                
                // Create Google Sign In configuration object.
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                
                // Start the sign in flow!
                let googleUser = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController).user
                guard let idToken = googleUser.idToken?.tokenString else { throw AuthError.noToken }
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: googleUser.accessToken.tokenString
                )
                let user = try await Auth.auth().signIn(with: credential).user
                if let currentUser = try? await _getUserInfo(uid: user.uid) {
                    return currentUser
                } else {
                    return try await setUserInfo(user: user, platform: .google)
                }
            },
            kakaoSignIn: { @MainActor in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    if UserApi.isKakaoTalkLoginAvailable() {
                        UserApi.shared.loginWithKakaoTalk { _, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }
                            continuation.resume(returning: ())
                            return
                        }
                    } else {
                        UserApi.shared.loginWithKakaoAccount { _, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }
                            continuation.resume(returning: ())
                            return
                        }
                    }
                }
                let kakaoUser = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<KakaoSDKUser.User, Error>) in
                    UserApi.shared.me { user, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        guard let user else {
                            continuation.resume(throwing: AuthError.noUser)
                            return
                        }
                        continuation.resume(returning: user)
                    }
                }
                guard let account = kakaoUser.kakaoAccount,
                      let email = account.email,
                      let userID = kakaoUser.id else { throw AuthError.noKakaoInfo }
                let password = String(userID)
                do {
                    let userInfo = try await singUp(email, password)
                    return try await setUserInfo(user: userInfo, platform: .kakao)
                } catch {
                    if let error = error as NSError?,
                       error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        let userInfo = try await singIn(email, password)
                        return try await _getUserInfo(uid: userInfo.uid)
                    } else {
                        throw error
                    }
                }
            },
            appleSignIn: { @MainActor in
                do {
                    let user = try await oauthManager.appleSignIn()
                    if let currentUser = try? await _getUserInfo(uid: user.uid) {
                        return currentUser
                    } else {
                        let userInfo = try await setUserInfo(user: user, platform: .apple)
                        return userInfo
                    }
                } catch {
                    throw error
                }
            },
            appleDeleteUser: { @MainActor in
                guard let currentUser = Auth.auth().currentUser else { throw AuthError.noUser }
                _ = try await (oauthManager.deleteAccount(),
                               deleteUserInfo(currentUser.uid))
            },
            getUserInfo: {
                guard let currentUser = Auth.auth().currentUser else { throw AuthError.noUser }
                return try await _getUserInfo(uid: currentUser.uid)
            },
            incrementUserCoin: { point in
                guard let currentUser = Auth.auth().currentUser else { throw AuthError.noUser }
                try await database.collection("users").document(currentUser.uid).updateData(
                    ["coin": FieldValue.increment(Double(point))]
                )
            }
        )
    }()
}

fileprivate let database = Firestore.firestore()

fileprivate func _getUserInfo(uid: String) async throws -> CurrentUser {
    try await database.collection("users").document(uid).getDocument(as: CurrentUser.self)
}

fileprivate func setUserInfo(user: UserInfo, platform: CurrentUser.Platform) async throws -> CurrentUser {
    let currentUser: CurrentUser = .init(user: user, platform: platform)
    try database.collection("users").document(user.uid).setData(from: currentUser)
    return currentUser
}

fileprivate func updateNickname(_ uid: String, _ nickname: String) async throws -> Void {
    try await database.collection("users").document(uid).updateData(["nickname": nickname])
}

fileprivate func deleteUserInfo(_ uid: String) async throws -> Void {
    try await database.collection("users").document(uid).delete()
}

fileprivate func singIn(_ email: String, _ password: String) async throws -> UserInfo {
    let user = try await Auth.auth().signIn(
        withEmail: email,
        password: password
    ).user
    return user
}

fileprivate func singUp(_ email: String, _ password: String) async throws -> UserInfo {
    let user = try await Auth.auth().createUser(
        withEmail: email,
        password: password
    ).user
    return user
}
