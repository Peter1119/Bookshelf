//
//  BookmarkListViewReactor.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import ReactorKit

final class BookmarkListViewReactor: Reactor {
    // MARK: - Action
    enum Action {
        case loadBookmarks
        case selectBook(Book)
    }

    // MARK: - Mutation
    enum Mutation {
        case setBookmarks([Book])
        case setLoading(Bool)
        case presentDetail(Book)
    }

    // MARK: - State
    struct State {
        var bookmarks: [Book] = []
        var isLoading: Bool = false
        var selectedBook: Book?
    }

    // MARK: - Properties
    let initialState = State()
    private let fetchBookmarksUseCase: FetchBookmarksUseCaseProtocol

    init(fetchBookmarksUseCase: FetchBookmarksUseCaseProtocol) {
        self.fetchBookmarksUseCase = fetchBookmarksUseCase
    }

    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadBookmarks:
            return fetchBookmarksUseCase.execute()
                .flatMap { books in
                    Observable.from([
                        Mutation.setBookmarks(books),
                        Mutation.setLoading(false)
                    ])
                }
                .startWith(Mutation.setLoading(true))

        case .selectBook(let book):
            return .just(Mutation.presentDetail(book))
        }
    }

    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setBookmarks(let books):
            newState.bookmarks = books
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .presentDetail(let book):
            newState.selectedBook = book
        }

        return newState
    }
}
