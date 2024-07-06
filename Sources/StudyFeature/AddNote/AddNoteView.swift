import CommonUI
import ComposableArchitecture
import Models
import SwiftUI

@ViewAction(for: AddNoteFeature.self)
public struct AddNoteView: View {
    @Bindable public var store: StoreOf<AddNoteFeature>
    
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
                                    .border(!isSame ? Color.gray4 : Color.clear, 20)
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
                            HStack {
                                Group {
                                    Text(word.wordString)
                                    Text("|")
                                    Text(word.wordMeaning)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { indexSet in
                            send(.deleteWordButtonTapped(indexSet))
                        }
                    }
                    .emptyList(list: store.wordList, title: "등록된 단어가 없어요.")
                    .listStyle(.plain)
                    .frame(height: 200)
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
