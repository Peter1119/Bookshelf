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
        case loadMoreSearchResults
        case search(String) // 검색어 변경
    }
    
    // MARK: - 상태 변경 작업
    enum Mutation {
        case setRecentBooks([Book])
        case setSearchResults([Book])
        case appendSearchResults([Book])
        case setCurrentPage(Int)
        case setLoading(Bool)
        case setHasMore(Bool)
        case setCurrentQuery(String)
    }
    
    // MARK: - State(View가 보여줄 상태)
    struct State {
        var recentBooks: [Book] = []      // 최근 본 책
        var searchResults: [Book] = []    // 검색 결과
        
        var currentPage: Int = 1
        var isLoading = false
        var hasMore: Bool = true
        var currentQuery: String = ""
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
            
        case .search(let query):
            guard !query.isEmpty else {
                return Observable.from([
                    Mutation.setSearchResults([]),
                    Mutation.setCurrentPage(1),
                    Mutation.setHasMore(true),
                    Mutation.setCurrentQuery(query)
                ])
            }
            return searchBookUseCase.execute(query: query, page: 1)
                .flatMap { bookResult in
                    Observable.from([
                        Mutation.setSearchResults(bookResult.books),
                        Mutation.setCurrentPage(1),
                        Mutation.setHasMore(!bookResult.isEnd),
                        Mutation.setLoading(false)
                    ])
                }
                .startWith(
                    Mutation.setLoading(true),
                    Mutation.setCurrentQuery(query)
                )
                .catch { error in
                    Observable.from([
//                        Mutation.setError(error),
                        Mutation.setLoading(false)
                    ])
                }
        case .loadMoreSearchResults:
            guard
                !currentState.isLoading,
                    currentState.hasMore,
                !currentState.currentQuery.isEmpty else {
                return .empty()
            }
            let nextPage = currentState.currentPage + 1
            return searchBookUseCase.execute(query: currentState.currentQuery, page: nextPage)
                .flatMap { bookResult in
                    Observable.from([
                        Mutation.appendSearchResults(bookResult.books),
                        Mutation.setCurrentPage(nextPage),
                        Mutation.setHasMore(!bookResult.isEnd),
                        Mutation.setLoading(false)
                    ])
                }
                .startWith(Mutation.setLoading(true))
                .catch { _ in
                        .just(Mutation.setLoading(false))
                }
        }
    }
    
    // MARK: - Mutation으로 State를 변경
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setRecentBooks(let books):
            newState.recentBooks = books
        case .setSearchResults(let books):
            newState.searchResults = books
        case .appendSearchResults(let newBooks):
            newState.searchResults.append(contentsOf: newBooks)
        case .setCurrentPage(let page):
            newState.currentPage = page
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setCurrentQuery(let query):
            newState.currentQuery = query
        }

        return newState
    }
}
