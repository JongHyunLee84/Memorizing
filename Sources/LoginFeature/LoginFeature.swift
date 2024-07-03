import ComposableArchitecture

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State {
        public init() {
            
        }
    }
    
    public enum Action {
        
    }
    
    public init() {
        
    }
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
    
    
}
