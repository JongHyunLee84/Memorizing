import Dependencies
import FirebaseFirestore
import Models
import NoteClient

extension NoteClient: DependencyKey {
    public static var liveValue = Self(
        getNoteList: { userID in
            let snapshot = try await getNoteCollection(userID)
                .order(by: "repeatCount")
                .getDocuments()
            return try snapshot.documents.tryMap { try $0.data(as: Note.self) }
        },
        getWordList: { userID, noteID in
            let snapshot = try await getWordCollection(userID, noteID)
                .order(by: "wordLevel")
                .getDocuments()
            return try snapshot.documents.tryMap { try $0.data(as: Word.self) }
        },
        saveNote: { userID, note in
            try getNoteDocument(userID, note.id)
                .setData(from: note)
        },
        saveWord: { userID, noteID, word in
            try getWordDocument(userID, noteID, word.id)
                .setData(from: word)
        },
        saveWordList: { userID, noteID, wordList in
            try getNoteDocument(userID, noteID)
                .setData(from: wordList)
        },
        deleteNote: { userID, note in
            // 하위 컬렉션도 다 삭제해줘야함.
            note.wordList.forEach {
                getWordDocument(userID, note.id, $0.id)
                    .delete()
            }
            getNoteDocument(userID, note.id)
                .delete()
        },
        deleteWord: { userID, noteID, wordID in
            getWordDocument(userID, noteID, wordID)
                .delete()
        },
        incrementRepeatCount: { userID, noteID in
            getNoteDocument(userID, noteID)
                .updateData([
                    "repeatCount": FieldValue.increment(Int64(1))
                ])
        },
        setNextStudyDate: { userID, noteID, date in
            getNoteDocument(userID, noteID)
                .updateData([
                    "nextStudyDate": date
                ])
        },
        setFirstTestResult: { userID, noteID, result in
            getNoteDocument(userID, noteID)
                .updateData([
                    "firstTestResult": result
                ])
        },
        setLastTestResult: { userID, noteID, result in
            getNoteDocument(userID, noteID)
                .updateData([
                    "lastTestResult": result
                ])
            
        },
        resetRepeatCount: { userID, noteID in
            @Dependency(\.date) var date
            getNoteDocument(userID, noteID)
                .updateData([
                    "repeatCount": 0,
                    "nextStudyDate": NSNull(), // 태영 수정
                    "updateDate" : date(),
                    "firstTestResult" : NSNull(),
                    "LastTestResult" : NSNull()
                ])
        },
        updateWordLevel: { userID, noteID, wordID, level in
            getWordDocument(userID, noteID, wordID)
                .updateData([
                    "wordLevel": level
                ])
            
        }
    )
}

fileprivate let database = Firestore.firestore()
fileprivate let userCollection = database.collection("users")

fileprivate func getNoteCollection(
    _ userID: String
) -> CollectionReference {
    userCollection
        .document(userID)
        .collection("myWordNotes")
}

fileprivate func getWordCollection(
    _ userID: String,
    _ noteID: String
) -> CollectionReference {
    userCollection
        .document(userID)
        .collection("myWordNotes")
        .document(noteID)
        .collection("words")
}

fileprivate func getNoteDocument(
    _ userID: String,
    _ noteID: String
) -> DocumentReference {
    getNoteCollection(userID)
        .document(noteID)
}

fileprivate func getWordDocument(
    _ userID: String,
    _ noteID: String,
    _ wordID: String
) -> DocumentReference {
    getWordCollection(userID, noteID)
        .document(wordID)
}
