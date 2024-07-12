import Dependencies
import FirebaseFirestore
import MarketClient
import Models

extension MarketClient: DependencyKey {
    public static let liveValue = Self(
        getSellableNoteList: { userID in
            let myNoteCollection = database.collection("users")
                .document(userID)
                .collection("myWordNotes")
            let snapshot = try await myNoteCollection.getDocuments()
            return try await withThrowingTaskGroup(of: Note.self) { group in
                var noteList: NoteList = []
                snapshot.documents.forEach { document in
                    group.addTask {
                        var note = try document.data(as: Note.self)
                        let wordListSnapshot = try await myNoteCollection.document(document.documentID).collection("words").getDocuments()
                        note.wordList = try wordListSnapshot.documents.tryMap { try $0.data(as: Word.self) }
                        return note
                    }
                }
                for try await note in group {
                    noteList.append(note)
                }
                
                // 단어가 20개 이상인 노트만 판매 가능
                return noteList.filter { $0.wordList.count >= 20 }
            }
        },
        getMarketList: {
            let snapshot = try await marketCollection.getDocuments()
            return try await withThrowingTaskGroup(of: MarketNote.self) { group in
                var marketNoteList: MarketNoteList = []
                snapshot.documents.forEach { document in
                    group.addTask {
                        var marketNote = try document.data(as: MarketNote.self)
                        marketNote.wordList = try await _getWordList(document.documentID)
                        return marketNote
                    }
                }
                
                for try await marketNote in group {
                    marketNoteList.append(marketNote)
                }
                
                return marketNoteList
            }
        },
        getWordList: { noteID in
            try await _getWordList(noteID)
        },
        postMarketNote: { note, price in
            @Dependency(\.date.now) var now
            try marketCollection
                .document(note.id)
                .setData(from:
                            MarketNote(
                                id: note.id,
                                noteName: note.noteName,
                                noteCategory: note.noteCategory,
                                enrollmentUser: note.enrollmentUser,
                                notePrice: price,
                                updateDate: now
                            )
                )
            try await _postWordList(note.id, note.wordList)
        },
        postWordList: { noteID, wordList in
            try await _postWordList(noteID, wordList)
        },
        getIsBuyable: { userID, price in
            try await _getIsBuyable(userID, price)
        },
        buyNote: { userID, note in
            let price = note.notePrice
            let isBuyable = try await _getIsBuyable(userID, price)
            if isBuyable {
                _ = try await (_updateUserCoin(userID, -price), // 구매자의 코인 차감,
                               _updateUserCoin(note.enrollmentUser, price)) // 판매자의 코인 증가
            } else {
                throw MarketError.noCoin
            }
        },
        deleteNote: { noteID in
            getNoteDocument(noteID).delete()
        }
    )
}

enum  MarketError: Error {
    case noCoin
}

fileprivate let database = Firestore.firestore()
fileprivate let marketCollection = database.collection("marketWordNotes")

fileprivate func getNoteDocument(_ noteID: String) -> DocumentReference {
    marketCollection
        .document(noteID)
}

fileprivate func getWordCollection(_ noteID: String) -> CollectionReference {
    marketCollection
        .document(noteID)
        .collection("words")
}

fileprivate func _getWordList(_ noteID: String) async throws -> MarketWordList {
    let snapshot = try await getWordCollection(noteID).getDocuments()
    return try snapshot.documents.tryMap { try $0.data(as: MarketWord.self) }
}

fileprivate func _postWordList(_ noteID: String, _ wordList: WordList) async throws -> Void {
    let wordCollection = getWordCollection(noteID)
    try await withThrowingTaskGroup(of: Void.self) { group in
        wordList
            .forEach { word in
                group.addTask {
                    try wordCollection
                        .document(word.id)
                        .setData(from: word)
                }
            }
        
        for try await _ in group {}
    }
}

fileprivate func _getIsBuyable(_ userID: String, _ price: Int) async throws -> Bool {
    let user = try await database.collection("users").document(userID).getDocument(as: CurrentUser.self)
    return user.coin >= price
}

fileprivate func _updateUserCoin(_ userID: String, _ changeCoin: Int) async throws -> Void {
    try await database.collection("users").document(userID).updateData([
        "coin" : FieldValue.increment(Int64(changeCoin))
    ])
}
