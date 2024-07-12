import ComposableArchitecture
import CommonUI
import Utilities
import Models
import SwiftUI

@Reducer
public struct StudyFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared public var note: Note
        public var currentWordIdx: Int
        public var isStudyConverted: Bool
        public var isWordConverted: Bool
        public var isStudyCompleted: Bool
        
        public init(
            note: Shared<Note>,
            currentWordIdx: Int = 0,
            isStudyConverted: Bool = false,
            isWordConverted: Bool = false,
            isStudyCompleted: Bool = false
        ) {
            self._note = note
            self.currentWordIdx = currentWordIdx
            self.isStudyConverted = isStudyConverted
            self.isWordConverted = isWordConverted
            self.isStudyCompleted = isStudyCompleted
        }
        
        public var studyPrgress: CGFloat {
            CGFloat(currentWordIdx + 1 / max(1,(note.wordList.count)))
        }
        
        public var isFirstOrLastStudy: Bool {
            note.repeatCount == 0 || note.repeatCount >= 3
        }
        
        public var testResult: Double {
            let totalScore = note.wordList.map { $0.wordLevel }.reduce(0, +)
            let maxScore = note.wordList.count * 2
            return Double(totalScore) / Double(maxScore)
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case studyComplete
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case backButtonTapped
            case wordTapped
            case levelButtonTapped(WordLevel)
            case beforeButtonTapped
            case nextButtonTapped
            case endButtonTapped
            case studyFinishButtonTapped
            case studyResetButtonTapped
        }
    }
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case .view(.endButtonTapped):
                state.note.repeatCount += 1
                return .run { _ in
                    await dismiss()
                }
                
            case .view(.studyFinishButtonTapped):
                if state.note.repeatCount == 0 {
                    state.note.firstTestResult = state.testResult
                } else {
                    state.note.lastTestResult = state.testResult
                }
                state.note.repeatCount += 1
                return .run { _ in
                    await dismiss()
                }
                
            case .view(.studyResetButtonTapped):
                state.note.repeatCount = 0
                state.note.firstTestResult = 0
                state.note.lastTestResult = 0
                return .run { _ in
                    await dismiss()
                }
                
            case .view(.wordTapped):
                state.isWordConverted.toggle()
                return .none
                
            case let .view(.levelButtonTapped(level)):
                state.note.wordList[state.currentWordIdx].wordLevel = level.rawValue
                if (state.currentWordIdx + 1) == state.note.wordList.count {
                    return .send(.studyComplete)
                } else {
                    state.currentWordIdx += 1
                    return .none
                }
                
            case .view(.beforeButtonTapped):
                state.currentWordIdx = max(0, state.currentWordIdx - 1)
                return .none
                
            case .view(.nextButtonTapped):
                if state.currentWordIdx == state.note.wordList.count - 1 {
                    return .send(.studyComplete)
                } else {
                    state.currentWordIdx += 1
                    return .none
                }
                
            case .studyComplete:
                state.isStudyCompleted = true
                return .none
                
            case .view(.binding):
                return .none
                
            }
        }
        .onChange(of: \.currentWordIdx) { _, _ in
            Reduce { state, _ in
                state.isWordConverted = false
                return .none
            }
        }
    }
}

@ViewAction(for: StudyFeature.self)
public struct StudyView: View {
    @Bindable public var store: StoreOf<StudyFeature>
    
    public init(store: StoreOf<StudyFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            StudyProgressBar()
                .padding(.horizontal, -16)
            WordToggleView()
            WordView()
            if !store.isStudyCompleted {
                StudyButtons()
            } else {
                StudyCompleteButtons()
            }
        }
        .padding(.horizontal, 16)
        .navigationSetting()
        .toolbar {
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
            TitleToolbarItem(title: store.note.noteName)
        }
    }
    
    private func StudyProgressBar() -> some View {
        Rectangle()
            .fill(Color.gray4)
            .frame(height: 2)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(Color.mainBlue)
                        .frame(width: proxy.size.width * store.studyPrgress)
                        .animation(.default, value: store.studyPrgress)
                }
            }
    }
    
    private func WordToggleView() -> some View {
        HStack {
            Spacer()
            Toggle("거꾸로 학습하기", isOn: $store.isStudyConverted)
                .textStyler(color: store.isStudyCompleted ? .gray4 : .mainBlack,
                            font: .caption,
                            weight: .semibold)
                .fixedSize()
                .disabled(store.isStudyCompleted)
        }
    }
    
    private func WordView() -> some View {
        Rectangle()
            .fill(.clear)
            .border(.gray4, radius: 20)
            .overlay(alignment: .topLeading) {
                Text("\(store.currentWordIdx + 1) / \(store.note.wordList.count)")
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .textStyler(color: .gray3, font: .callout)
            }
            .overlay {
                VStack {
                    if let word = store.note.wordList[safe: store.currentWordIdx],
                       !store.isStudyCompleted {
                        if !store.isWordConverted {
                            // 문제
                            Text(store.isStudyConverted
                                 ? word.wordMeaning
                                 : word.wordString)
                        } else {
                            // 정답
                            Text(store.isStudyConverted
                                 ? word.wordString
                                 : word.wordMeaning)
                            .textColor(.mainBlue)
                        }
                    } else {
                        Group {
                            if store.isFirstOrLastStudy {
                                if store.testResult >= 0.75 {
                                    Image.goodIcon
                                        .resizable()
                                } else {
                                    Image.failIcon
                                        .resizable()
                                }
                            } else {
                                Image.studyIcon
                                    .resizable()
                            }
                        }
                        .frame(width: 200, height: 200)
                    }
                }
                .textStyler(font: .largeTitle,
                            weight: .semibold)
                .padding(.horizontal, 16)
            }
            .contentShape(.rect)
            .onTapGesture {
                send(.wordTapped)
            }
    }
    
    private func CheckLevelButtons() -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width / 3 - 18
            HStack(spacing: 9) {
                ForEach(WordLevel.allCases, id: \.self) { level in
                    LevelButton(level) {
                        send(.levelButtonTapped(level))
                    }
                    .frame(width: width, height: width)
                    .background(level.buttonInfo.color)
                    .cornerRadius(20)
                    if level != .easy {
                        Spacer()
                    }
                }
            }
        }
        .frame(height: 150)
    }
    
    private func LevelButton(
        _ level: WordLevel,
        action: @escaping () -> Void
    ) -> some View {
        Button(
            action: {
                action()
            }, label: {
                VStack(spacing: 12) {
                    level.buttonInfo.image
                    Text(level.buttonInfo.title)
                        .textStyler(color: .white,
                                    font: .body,
                                    weight: .semibold)
                }
            }
        )
    }
    
    private func WordIdxChangeButtons() -> some View {
        HStack {
            MainButton(title: "이전",
                       font: .headline) {
                send(.beforeButtonTapped)
            }
            Spacer()
            MainButton(title: "다음",
                       font: .headline) {
                send(.nextButtonTapped)
            }
        }
        .frame(height: 150)
    }
    
    @ViewBuilder
    private func StudyButtons() -> some View {
        if store.isFirstOrLastStudy {
            CheckLevelButtons()
        } else {
            WordIdxChangeButtons()
        }
    }
    
    @ViewBuilder
    private func StudyCompleteButtons() -> some View {
        Group {
            if store.isFirstOrLastStudy {
                VStack(spacing: 12) {
                    MainButton(title: "학습 마무리하기",
                               font: .headline) {
                        send(.studyFinishButtonTapped)
                    }
                    MainButton(title: "처음부터 복습하기",
                               font: .headline) {
                        send(.studyResetButtonTapped)
                    }
                }
            } else {
                MainButton(title: "종료하기",
                           font: .headline) {
                    send(.endButtonTapped)
                }
            }
        }
        .frame(height: 150)
    }
}

public enum WordLevel: Int, CaseIterable {
    case hard = 0
    case normal = 1
    case easy = 2
    
    var buttonInfo: ButtonInfo {
        switch self {
        case .hard:
                .init(title: "모르겠어요", color: .gray2, image: .badFace)
        case .normal:
                .init(title: "애매해요", color: .mainBlue, image: .normalFace)
        case .easy:
                .init(title: "외웠어요", color: .mainDarkBlue, image: .goodFace)
        }
    }
}

struct ButtonInfo {
    let title: String
    let color: Color
    let image: Image
}

#Preview {
    return NavigationStack {
        StudyView(
            store: .init(
                initialState: .init(note: Shared(.mock)),
                reducer: { StudyFeature()._printChanges() }
            )
        )
    }
}
