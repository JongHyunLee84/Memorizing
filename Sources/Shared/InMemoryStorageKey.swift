import ComposableArchitecture
import Models

extension PersistenceReaderKey where Self == PersistenceKeyDefault<InMemoryKey<CurrentUser?>> {
  public static var currentUser: Self {
      PersistenceKeyDefault(.inMemory("CurrentUser"), nil)
  }
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<InMemoryKey<String?>> {
    public static var toastMessage: Self {
        PersistenceKeyDefault(.inMemory("ToastMessage"), nil)
    }
}
