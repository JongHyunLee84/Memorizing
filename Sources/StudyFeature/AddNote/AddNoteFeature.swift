import ComposableArchitecture
import Foundation
import Models
import Shared

@Reducer
public struct AddNoteFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.toastMessage) public var toastMessage
        public var noteName: String
        public var noteCategory: NoteCategory
        public var wordName: String
        public var wordMeaning: String
        public var wordList: WordList
        
        public init(noteName: String = "",
                    noteCategory: NoteCategory = .english,
                    wordName: String = "",
                    wordMeaning: String = "",
                    wordList: WordList = []
        ) {
            self.noteName = noteName
            self.noteCategory = noteCategory
            self.wordName = wordName
            self.wordMeaning = wordMeaning
            self.wordList = wordList
        }
        
        public var isWordContentFilled: Bool {
            !(wordName.isEmpty || wordMeaning.isEmpty)
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case sendToastMessage(String)
        case addNoteDelegate
        
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case saveButtonTapped
            case xButtonTapped
            case categoryButtonTapped(NoteCategory)
            case addWordButtonTapped
            case deleteWordButtonTapped(IndexSet)
        }
    }
    
    public init() {}
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.dismiss) var dismiss
    
    enum CancelID: Error {
        case message
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            // client의 작업을 기다렸다가 dismiss 해야하기 때문에 parent view에서 save 작업 실행
            case .view(.saveButtonTapped):
                if !state.noteName.isEmpty {
                    return .run { send in
                        await send(.addNoteDelegate)
                        await dismiss()
                    }
                } else {
                    return sendToastMessageEffect("암기장 이름을 입력해주세요")
                }

            case .view(.xButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case let .view(.categoryButtonTapped(category)):
                state.noteCategory = category
                return .none
                
            case .view(.addWordButtonTapped):
                state.wordList.append(.init(wordString: state.wordName,
                                            wordMeaning: state.wordMeaning))
                state.wordName = ""
                state.wordMeaning = ""
                return .none
                
            case let .view(.deleteWordButtonTapped(index)):
                state.wordList.remove(atOffsets: index)
                return .none
                
            case .view(.binding(\.noteName)):
                if state.noteName.count > 50 {
                    state.noteName = String(state.noteName.prefix(50))
                    return sendToastMessageEffect("최대 50글자까지만 입력해주세요.")
                }
                return .none
                
            case .view(.binding(\.wordName)):
                if state.wordName.count > 50 {
                    state.wordName = String(state.wordName.prefix(50))
                    return sendToastMessageEffect("최대 50글자까지만 입력해주세요.")
                }
                return .none
                
            case .view(.binding(\.wordMeaning)):
                if state.wordMeaning.count > 50 {
                    state.wordMeaning = String(state.wordMeaning.prefix(50))
                    return sendToastMessageEffect("최대 50글자까지만 입력해주세요.")
                }
                return .none
                
            case let .sendToastMessage(message):
                state.toastMessage = message
                return .none
                
            case .view(.binding):
                return .none
                
            case .addNoteDelegate:
                return .none

            }
        }
    }
    
    private func sendToastMessageEffect(_ message: String) -> Effect<Action> {
        .run { send in
            try await clock.sleep(for: .seconds(0.3))
            await send(.sendToastMessage(message))
        }
        .cancellable(id: CancelID.message, cancelInFlight: true)
    }
}
