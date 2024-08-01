import Dependencies
import FirebaseFirestore
import MyReviewClient
import Models

extension MyReviewClient: DependencyKey {
    public static var liveValue = Self(
        getReviewList: { userID in
            let snapshot = try await getReviewCollection(userID)
                .getDocuments()
            return try snapshot.documents.tryMap { try $0.data(as: MyReview.self) }
        },
        postReview: { userID, review in
            try getReviewDocument(userID, review.id)
                .setData(from: review)
        },
        deleteReview: { userID, reviewID in
            getReviewDocument(userID, reviewID)
                .delete()
        }
    )
}

fileprivate let database = Firestore.firestore()
fileprivate let userCollection = database.collection("users")

fileprivate func getReviewCollection(
    _ userID: String
) -> CollectionReference {
    userCollection
        .document(userID)
        .collection("reviews")
}

fileprivate func getReviewDocument(
    _ userID: String,
    _ reviewID: String
) -> DocumentReference {
    getReviewCollection(userID)
        .document(reviewID)
}
