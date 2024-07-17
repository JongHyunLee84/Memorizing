import ComposableArchitecture
import CommonUI
import Foundation
import Models
import Shared
import SwiftUI

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
        public var note: Note?
        
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
        
        public init(note: Note) {
            self.noteName = note.noteName
            self.noteCategory = note.category
            self.wordName = ""
            self.wordMeaning = ""
            self.wordList = note.wordList
            self.note = note
        }
        
        public var isWordContentFilled: Bool {
            !(wordName.isEmpty || wordMeaning.isEmpty)
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case sendToastMessage(String)
        
        @CasePathable
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
                if state.wordList.count < 50 {
                    state.wordList.append(.init(wordString: state.wordName,
                                                wordMeaning: state.wordMeaning))
                    state.wordName = ""
                    state.wordMeaning = ""
                    return .none
                } else {
                    return sendToastMessageEffect("최대 50개까지만 추가해주세요.")
                }
                
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

// TODO: 코드 정리
@ViewAction(for: AddNoteFeature.self)
public struct AddNoteView: View {
    @Bindable public var store: StoreOf<AddNoteFeature>
    
    public init(store: StoreOf<AddNoteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {
                
                VStack(alignment: .leading) {
                    Text("암기장 이름")
                    TextField("암기장 이름을 입력해주세요. (필수)",
                              text: $store.noteName)
                    .font(.caption)
                    .padding(.leading)
                    .frame(height: 46)
                    .background(Color.gray5.cornerRadius(20))
                }
                
                VStack(alignment: .leading) {
                    Text("카테고리")
                    ScrollView(.horizontal) {
                        HStack(spacing: 4) {
                            ForEach(NoteCategory.allCases, id: \.self) { category in
                                let isSame = store.noteCategory == category
                                Text(category.rawValue)
                                    .textStyler(color: isSame ? .white : .gray5,
                                                font: .caption)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .frame(width: 65)
                                    .background((isSame ? category.noteColor : .white))
                                    .border(!isSame ? Color.gray4 : Color.clear, radius: 20)
                                    .onTapGesture {
                                        send(.categoryButtonTapped(category))
                                    }
                            }
                        }
                    }
                    .scrollIndicators(.never)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("암기 항목 (단어/질문 등)")
                        Spacer()
                        Text("\(store.wordName.count)/50 글자") // TODO:
                            .font(.caption)
                    }
                    CustomTextEditor(placeholder: "암기해야 할 내용을 단어, 질문 등의 형식으로 자유롭게 입력해보세요 :)",
                                     text: $store.wordName) // TODO:
                    .frame(height: 100)
                    
                    Text("* 하나의 암기장에 암기항목은 최대 50개까지 추가 가능해요.")
                        .textStyler(color: .gray4, font: .caption2)
                        .padding(.bottom, 10)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("의미")
                        Spacer()
                        Text("\(store.wordMeaning.count)/50 글자") // TODO:
                            .font(.caption)
                    }
                    CustomTextEditor(placeholder: "해당 암기 내용의 뜻, 의미 등을 입력해주세요.",
                                     text: $store.wordMeaning) // TODO:
                    .frame(height: 100)
                    
                }
                
                MainButton(title: "추가하기",
                           backgroundColor: .gray4,
                           height: 50,
                           isAvailable: store.isWordContentFilled) {
                    send(.addWordButtonTapped)
                }
                
                LazyVStack(alignment: .leading) {
                    let wordNumberText = Text("\(store.wordList.count)").foregroundStyle(Color.mainBlue)
                    Text("총 \(wordNumberText)개의 단어") // TODO:
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    List {
                        ForEach(store.wordList) {
                            word in
                            WordCell(wordString: word.wordString,
                                     wordMeaning: word.wordMeaning)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { indexSet in
                            send(.deleteWordButtonTapped(indexSet))
                        }
                    }
                    .frame(height: 100)
                    .emptyList(list: store.wordList,
                               title: "등록된 단어가 없어요.")
                    .listStyle(.plain)
                }
            }
            .textStyler(font: .callout, weight: .semibold)
            
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .toolbar {
            TitleToolbarItem(title: "새로운 암기장 만들기")
            XToolbarItem {
                send(.xButtonTapped)
            }
            TextToolbarItem(placement: .topBarLeading,
                            text: "저장하기") {
                send(.saveButtonTapped)
            }
        }
        .toastMessage(messsage: $store.toastMessage)
    }
}

#Preview {
    NavigationStack {
        AddNoteView(
            store: .init(
                initialState: .init(),
                reducer: { AddNoteFeature()._printChanges() }
            )
        )
    }
}
