//
//  BookSearchViewReactor.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation
import ReactorKit

final class BookSearchViewReactor: Reactor {
    // MARK: - Action (사용자 입력)
    enum Action {
        case loadRecentBooks     // 최근 본 책 로드
        case updateQuery(String) // 검색어 변경
    }
    
    // MARK: - 상태 변경 작업
    enum Mutation {
        case setRecentBooks([Book])
        case setSearchResults([Book])
    }
    
    // MARK: - State(View가 보여줄 상태)
    struct State {
        var query: String = ""
        var recentBooks: [Book] = []      // 최근 본 책
        var searchResults: [Book] = []    // 검색 결과
    }
    
    // MARK: - Properties
    var initialState: State = State()
    private let searchBookUseCase: SearchBookUseCaseProtocol
    private let fetchRecentBooksUseCase: FetchRecentBooksUseCaseProtocol

    init(
        searchBookUseCase: SearchBookUseCaseProtocol,
        fetchRecentBooksUseCase: FetchRecentBooksUseCaseProtocol
    ) {
        self.searchBookUseCase = searchBookUseCase
        self.fetchRecentBooksUseCase = fetchRecentBooksUseCase
    }
    
    // MARK: - Mutate (Action을 Mutation으로 변환)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadRecentBooks:
            return fetchRecentBooksUseCase.execute()
                .map { Mutation.setRecentBooks($0) }

        case .updateQuery(let query):
            return searchBookUseCase.execute(query: query)
                .map { Mutation.setSearchResults($0) }
        }
    }
    
    // MARK: - Mutation으로 State를 변경
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setRecentBooks(books):
            newState.recentBooks = books

        case let .setSearchResults(books):
            newState.searchResults = books
        }

        return newState
    }
}
