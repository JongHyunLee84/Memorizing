import Dependencies
import FirebaseFirestore
import Models
import ReviewClient

extension ReviewClient: DependencyKey {
    public static var liveValue = Self(
        getReviewList: { noteID in
            let snapshot = try await getReviewCollection(noteID)
                .getDocuments()
            return try snapshot.documents.compactMap {
                try $0.data(as: Review.self)
            }
        },
        getReviewListWithLimit: { noteID, limit in
            let snapshot = try await getReviewCollection(noteID)
                .limit(to: limit)
                .getDocuments()
            return try snapshot.documents.compactMap {
                try $0.data(as: Review.self)
            }
        },
        postReview: { noteID, review in
            try getReviewDocument(noteID, review.id)
                .setData(from: review)
        },
        updateMarketNoteReviewData: { noteID, review in
            marketCollection
                .document(noteID)
                .updateData([
                    "reviewCount": FieldValue.increment(Int64(1)),
                    "starScoreTotal": FieldValue.increment(Int64(review.starScore))
                ])
            
        },
        deleteReview: { noteID, reviewID in
            getReviewDocument(noteID, reviewID)
                .delete()
        }
    )
}

fileprivate let database = Firestore.firestore()
fileprivate let marketCollection = database.collection("marketWordNotes")

fileprivate func getReviewCollection(
    _ noteID: String
) -> CollectionReference {
    marketCollection
        .document(noteID)
        .collection("reviews")
}

fileprivate func getReviewDocument(
    _ noteID: String,
    _ reviewID: String
) -> DocumentReference {
    getReviewCollection(noteID)
        .document(reviewID)
}
