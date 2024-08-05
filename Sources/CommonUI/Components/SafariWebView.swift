import SwiftUI
import SafariServices

public struct SafariWebView: UIViewControllerRepresentable {
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    SafariWebView(url: URL(string: "https://memorizing.notion.site/4b2f1810b30e42ba84cd5706622db5cf")!)
}

