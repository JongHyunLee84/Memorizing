import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct MemorizingApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                
            }
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
