import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Foundation
import Models

actor OAuthManager {
    var appleOAuthDelegate: AppleOAuthDelegate?
    
    func appleSignIn() async throws -> UserInfo {
        
        let stream = AsyncThrowingStream<UserInfo, Error> { continuation in
            self.appleOAuthDelegate = AppleOAuthDelegate(
                didFinishAppleLogin: { result in
                    switch result {
                    case let .success(user):
                        continuation.yield(user)
                        continuation.finish()
                    case let .failure(error):
                        continuation.finish(throwing: error)
                    }
                }
            )
            let nonce = randomNonceString()
            self.appleOAuthDelegate?.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self.appleOAuthDelegate
            controller.presentationContextProvider = self.appleOAuthDelegate
            controller.performRequests()
        }
        
        for try await user in stream {
            return user
        }
        
        throw CancellationError()
    }
    
    func deleteAccount() async throws -> Void {
        let stream = AsyncThrowingStream<String, Error> { continuation in
            self.appleOAuthDelegate = AppleOAuthDelegate(
                didFinishDeleteAccount: { result in
                    switch result {
                    case let .success(authCode):
                        continuation.yield(authCode)
                        continuation.finish()
                    case let .failure(error):
                        continuation.finish(throwing: error)
                    }
                }
            )
            let nonce = randomNonceString()
            self.appleOAuthDelegate?.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self.appleOAuthDelegate
            authorizationController.presentationContextProvider = self.appleOAuthDelegate
            authorizationController.performRequests()
        }
        
        for try await authCodeString in stream {
            _ = try await (Auth.auth().revokeToken(withAuthorizationCode: authCodeString),
                           Auth.auth().currentUser?.delete())
        }
        
        throw CancellationError()
    }
    
}

typealias LoginResult = Result<UserInfo, Error>
typealias DeleteResult = Result<String, Error>

final class AppleOAuthDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    var didFinishAppleLogin: @Sendable (LoginResult) -> Void
    var didFinishDeleteAccount: @Sendable (DeleteResult) -> Void
    
    var currentNonce: String?
    
    init(
        didFinishAppleLogin: @escaping @Sendable (LoginResult) -> Void = { _ in },
        didFinishDeleteAccount: @escaping @Sendable (DeleteResult) -> Void = { _ in },
        currentNonce: String? = nil
    ) {
        self.didFinishAppleLogin = didFinishAppleLogin
        self.didFinishDeleteAccount = didFinishDeleteAccount
        self.currentNonce = currentNonce
    }
    
    // MARK: - Apple
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            didFinishAppleLogin(.failure(AuthError.noAppleLoginResult))
            didFinishDeleteAccount(.failure(AuthError.noAppleLoginResult))
            return
        }
        handleLogin(appleIDCredential)
        handleDelete(appleIDCredential)
    }
    
    // Error 발생
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        didFinishAppleLogin(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else {
            fatalError("Unable to find a valid window scene")
        }
        return window
    }
    
    private func handleLogin(_ credential: ASAuthorizationAppleIDCredential) -> Void {
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = credential.identityToken else {
            didFinishAppleLogin(.failure(AuthError.noAppleLoginResult))
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            didFinishAppleLogin(.failure(AuthError.decode))
            return
        }
        
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: credential.fullName)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                self.didFinishAppleLogin(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                self.didFinishAppleLogin(.failure(AuthError.noUser))
                return
            }
            // User is signed in to Firebase with Apple.
            self.didFinishAppleLogin(.success(user))
        }
        
    }
    
    private func handleDelete(_ credential: ASAuthorizationAppleIDCredential) -> Void {
        
        guard let _ = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let appleAuthCode = credential.authorizationCode else {
            didFinishDeleteAccount(.failure(AuthError.noAppleLoginResult))
            return
        }
        
        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
            didFinishDeleteAccount(.failure(AuthError.decode))
            return
        }
        
        didFinishDeleteAccount(.success(authCodeString))
        return
    }
}

fileprivate func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError(
            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
    }
    
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    
    let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
    }
    
    return String(nonce)
}

@available(iOS 13, *)
fileprivate func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}



