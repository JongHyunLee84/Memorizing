import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    SafariWebView(url: URL(string: "https://memorizing.notion.site/4b2f1810b30e42ba84cd5706622db5cf")!)
}

//"https://memorizing.notion.site/4b2f1810b30e42ba84cd5706622db5cf"
//"https://memorizing.notion.site/7186dcfc77794dd593dc292be31df131"
//TalkApi.shared.makeUrlForChannelChat(channelPublicId: "_hZrWxj")!)
