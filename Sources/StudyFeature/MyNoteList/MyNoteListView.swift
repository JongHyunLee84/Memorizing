import CommonUI
import ComposableArchitecture
import SwiftUI

@ViewAction(for: MyNoteListFeature.self)
public struct MyNoteListView: View {
    @Bindable public var store: StoreOf<MyNoteListFeature>
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.circle")
                    Text("진행 중인 암기만 보기")
                }
                .textStyler(color: store.showOnlyStudyingNote ? .mainBlue : .gray3,
                            font: .caption2)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .onTapGesture {
                    send(.showOnlyStudyingNoteButtonTapped)
                }
                .padding(.top, 12)
                
                ForEach(store.noteList) { note in
                    if !store.showOnlyStudyingNote {
                        NoteCell(note: note)
                    } else if note.repeatCount < 4 {
                        NoteCell(note: note)
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            PlusButton {
                send(.plusButtonTapped)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 16)
        .task {
            await send(.onAppear).finish()
        }
        .toolbar {
            AppLogoToolbarItem(placement: .topBarLeading)
            TitleToolbarItem(title: "내 암기장")
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $store.scope(state: \.destination?.addNote,
                                             action: \.destination.addNote)) { store in
            NavigationStack {
                AddNoteView(store: store)
            }
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        MyNoteListView(
            store: .init(
                initialState: .init(),
                reducer: { MyNoteListFeature()._printChanges() }
            )
        )
    }
}
