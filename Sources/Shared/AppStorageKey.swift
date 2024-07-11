import ComposableArchitecture

extension PersistenceReaderKey where Self == PersistenceKeyDefault<AppStorageKey<Bool>> {
  public static var showOnlyStudyingNote: Self {
      PersistenceKeyDefault(.appStorage("showOnlyStudyingNote"), false)
  }
}
