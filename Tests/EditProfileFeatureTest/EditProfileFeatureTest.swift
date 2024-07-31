import ComposableArchitecture
import EditProfileFeature
import Shared
import XCTest

final class EditProfileFeatureTest: XCTestCase {
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: EditProfileFeature.State(),
            reducer: { EditProfileFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_change_nickname_success() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: EditProfileFeature.State(),
            reducer: { EditProfileFeature() }
        )
        
        await store.send(\.view.binding.nicknameStr, "닉네임") {
            $0.nicknameStr = "닉네임"
        }
        await store.send(\.view.changeButtonTapped)
        await store.receive(\.toastMessage) {
            $0.toastMessage = "이름이 변경되었어요."
            $0.currentUser?.nickname = "닉네임"
        }
        await store.receive(\.resetNicknameStr) {
            $0.nicknameStr = ""
        }
    }
    
    @MainActor
    func test_change_nickname_fail() async {
        let store = TestStore(
            initialState: EditProfileFeature.State(),
            reducer: { EditProfileFeature() }
        )
        await store.send(\.view.changeButtonTapped)
        await store.receive(\.toastMessage) {
            $0.toastMessage = "이름을 입력해주세요."
        }
    }
    
    @MainActor
    func test_withdrawal_success() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: EditProfileFeature.State(),
            reducer: { EditProfileFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(\.view.withdrawalButtonTapped) {
            $0.alert = .withdrawalAlert
        }
        await store.send(\.alert.presented.confirmWithdrawal) {
            $0.alert = nil
        }
        XCTAssertEqual(isDismissInvoked.value, [true])
        store.assert {
            $0.currentUser = nil
        }
    }
    
    @MainActor
    func test_withdrawal_cancel() async {
        let store = TestStore(
            initialState: EditProfileFeature.State(),
            reducer: { EditProfileFeature() }
        )
        
        await store.send(\.view.withdrawalButtonTapped) {
            $0.alert = .withdrawalAlert
        }
        await store.send(\.alert.dismiss) {
            $0.alert = nil
        }
    }
    
    @MainActor
    func test_nicknameStr_max_length() async {
        let store = TestStore(
            initialState: EditProfileFeature.State(),
            reducer: { EditProfileFeature() }
        )
        await store.send(\.view.binding.nicknameStr, "123") {
            $0.nicknameStr = "123"
        }
        await store.send(\.view.binding.nicknameStr, "1234567") {
            $0.nicknameStr = "12345"
        }
    }
}
