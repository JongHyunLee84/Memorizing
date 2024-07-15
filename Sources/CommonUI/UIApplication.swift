import UIKit

extension UIApplication: UIGestureRecognizerDelegate {
    
    // MARK: - 호출 방법 : .onAppear (perform : UIApplication.shared.hideKeyboard)
    public func hideKeyboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self // gestureRecognizer, UIGestureRecognizerDelegate
        window.addGestureRecognizer(tapRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
