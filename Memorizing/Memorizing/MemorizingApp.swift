import ComposableArchitecture
import CoreApp
import FirebaseCore
import GoogleSignIn
import KakaoSDKCommon
import SwiftUI

@main
struct MemorizingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        let KAKAO_APP_KEY: String = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String ?? "KAKAO_APP_KEY is nil"
        KakaoSDK.initSDK(appKey: KAKAO_APP_KEY)
    }
    
    var body: some Scene {
        WindowGroup {
            CoreAppView(
                store: .init(
                    initialState: .init(),
                    reducer: { CoreApp() }
                )
            )
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // MARK: - Firebase Setting
        FirebaseApp.configure()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // MARK: - Google SignIn Setting
        return GIDSignIn.sharedInstance.handle(url)
    }
}
