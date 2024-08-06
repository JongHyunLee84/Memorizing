import ComposableArchitecture
import PopupView
import SwiftUI

struct CustomAlertModifier<A, M, T>: ViewModifier where A : View, M : View  {
    let title: Text
    @Binding var isPresented: Bool
    let data: T?
    let actions: (T) -> A
    let message: (T) -> M
    
    init(
        _ title: Text,
        isPresented: Binding<Bool>,
        presenting data: T?,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) {
        self.title = title
        self._isPresented = isPresented
        self.data = data
        self.actions = actions
        self.message = message
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented = false
                        }
                }
            }
            .popup(isPresented: .constant($isPresented.wrappedValue)) {
                    VStack(spacing: 12) {
                        title
                            .textStyler(font: .title3,
                                        weight: .semibold)
                        if let data {
                            message(data)
                            actions(data)
                        }
                    }
                    .padding(.all, 12)
                    .background(.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                } customize: {
                    $0
                        .appearFrom(.centerScale)
            }
    }
}

extension View {
    private func customAlert<A: View, M: View, T>(
        _ title: Text,
        isPresented: Binding<Bool>,
        presenting data: T? = nil,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        modifier(
            CustomAlertModifier(
                title,
                isPresented: isPresented,
                presenting: data,
                actions: actions,
                message: message
            )
        )
    }
    
    public func customAlert<Action>(_ item: Binding<Store<AlertState<Action>, Action>?>) -> some View {
        let store = item.wrappedValue
        let alertState = store?.withState { $0 }
        return self.customAlert(
            (alertState?.title).map(Text.init) ?? Text(verbatim: ""),
            isPresented: Binding.init(item),
            presenting: alertState,
            actions: { alertState in
                HStack {
                    ForEach(alertState.buttons) { button in
                        Button(role: button.role.map(ButtonRole.init)) {
                            switch button.action.type {
                            case let .send(action):
                                if let action {
                                    store?.send(action)
                                }
                            case let .animatedSend(action, animation):
                                if let action {
                                    store?.send(action, animation: animation)
                                }
                            }
                        } label: {
                            Text(button.label)
                                .fontWeight(.semibold)
                                .foregroundStyle(button.role == .cancel
                                                 ? Color.gray3 : .white)
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(button.role == .cancel
                                            ? Color.gray5 : .mainBlue)
                                .cornerRadius(10)
                        }
                    }
                }
            },
            message: {
                $0.message.map(Text.init)
            }
        )
    }
}

@Reducer
fileprivate struct AlertReducer {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case singleButtonTapped
        case doubleButtonTapped
    }
    
    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        
        @CasePathable
        enum Alert {
            case singleAlert
            case doubleAlert
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case .singleButtonTapped:
                state.destination = .alert(.singleAlert)
                return .none
            case .doubleButtonTapped:
                state.destination = .alert(.doubleAlert)
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == AlertReducer.Destination.Alert {
    fileprivate static let singleAlert = Self(
        title: { TextState("포인트를 얻는 방법") },
        actions: {
            ButtonState(role: .destructive, action: .singleAlert) {
                TextState("확인")
            }
        },
        message: {
            TextState("""
1. 4번의 확습을 완료하고 도장을 받아봐요~!
2. 사람들에게 나만의 암기장을 판매해봐요~!
3. 구매한 암기장에 리뷰를 작성해봐요~!
""")
        }
    )
    fileprivate static let doubleAlert = Self(
        title: { TextState("포인트를 얻는 방법") },
        actions: {
            ButtonState(role: .cancel) {
                TextState("취소")
            }
            ButtonState(role: .destructive, action: .doubleAlert) {
                TextState("확인")
            }
        },
        message: {
            TextState("""
1. 4번의 확습을 완료하고 도장을 받아봐요~!
2. 사람들에게 나만의 암기장을 판매해봐요~!
3. 구매한 암기장에 리뷰를 작성해봐요~!
""")
        }
    )
}

fileprivate struct AlertSampleView: View {
    @Bindable var store = Store(initialState: AlertReducer.State.init(),
                                reducer: { AlertReducer()._printChanges() })
    var body: some View {
        VStack {
            Button("Single Alert") {
                store.send(.singleButtonTapped)
            }
            Button("Double Alert") {
                store.send(.doubleButtonTapped)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customAlert($store.scope(state: \.destination?.alert, 
                                  action: \.destination.alert))
    }
}

#Preview {
    AlertSampleView()
}
