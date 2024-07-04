import ComposableArchitecture
import Models

extension PersistenceReaderKey where Self == PersistenceKeyDefault<InMemoryKey<CurrentUser?>> {
    
  public static var currentUser: Self {
      PersistenceKeyDefault(.inMemory("CurrentUser"), nil)
  }

}
