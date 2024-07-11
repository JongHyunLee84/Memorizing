import SwiftUI

struct NavigationSettingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
    }
}

extension View {
    public func navigationSetting() -> some View {
        modifier(NavigationSettingModifier())
    }
}

#Preview("With NavigationSetting") {
    NavigationStack(path: .constant(NavigationPath.init([1]))) {
        EmptyView()
        .navigationDestination(for: Int.self) { _ in
            VStack {
                Text("Destination")
                Spacer()
            }
            .navigationSetting()
            .toolbar {
                TitleToolbarItem(title: "Title")
                BackButtonToolbarItem() {}
            }
        }
    }
}

#Preview("Without NavigationSetting") {
    NavigationStack(path: .constant(NavigationPath.init([1]))) {
        EmptyView()
        .navigationDestination(for: Int.self) { _ in
            VStack {
                Text("Destination")
                Spacer()
            }
            .toolbar {
                TitleToolbarItem(title: "Title")
                BackButtonToolbarItem() {}
            }
        }
    }
}
