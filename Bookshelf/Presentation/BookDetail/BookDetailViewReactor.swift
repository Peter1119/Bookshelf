//
//  BookDetailViewReactor.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import ReactorKit
import RxSwift

final class BookDetailViewReactor: Reactor {
    // MARK: - Action (사용자 입력)
    enum Action {
        case toggleBookmark  // 담기/삭제 토글
        case checkBookmarkStatus  // 북마크 상태 확인
    }

    // MARK: - Mutation (상태 변경 작업)
    enum Mutation {
        case setBookmarked(Bool)
        case setLoading(Bool)
    }

    // MARK: - State (View가 보여줄 상태)
    struct State {
        var book: Book
        var isBookmarked: Bool = false
        var isLoading: Bool = false
    }

    // MARK: - Properties
    let initialState: State
    private let book: Book
    private let addBookmarkUseCase: AddBookmarkUseCaseProtocol
    private let removeBookmarkUseCase: RemoveBookmarkUseCaseProtocol
    private let checkBookmarkUseCase: CheckBookmarkUseCaseProtocol

    init(
        book: Book,
        addBookmarkUseCase: AddBookmarkUseCaseProtocol,
        removeBookmarkUseCase: RemoveBookmarkUseCaseProtocol,
        checkBookmarkUseCase: CheckBookmarkUseCaseProtocol
    ) {
        self.book = book
        self.initialState = State(book: book)
        self.addBookmarkUseCase = addBookmarkUseCase
        self.removeBookmarkUseCase = removeBookmarkUseCase
        self.checkBookmarkUseCase = checkBookmarkUseCase
    }

    // MARK: - Mutate (Action을 Mutation으로 변환)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkBookmarkStatus:
            return checkBookmarkUseCase.execute(book)
                .map { Mutation.setBookmarked($0) }

        case .toggleBookmark:
            let isCurrentlyBookmarked = currentState.isBookmarked

            if isCurrentlyBookmarked {
                return removeBookmarkUseCase.execute(book)
                    .flatMap { _ in
                        Observable.from([
                            Mutation.setBookmarked(false),
                            Mutation.setLoading(false)
                        ])
                    }
                    .startWith(Mutation.setLoading(true))
            } else {
                return addBookmarkUseCase.execute(book)
                    .flatMap { _ in
                        Observable.from([
                            Mutation.setBookmarked(true),
                            Mutation.setLoading(false)
                        ])
                    }
                    .startWith(Mutation.setLoading(true))
            }
        }
    }

    // MARK: - Reduce (Mutation으로 State를 변경)
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setBookmarked(let isBookmarked):
            newState.isBookmarked = isBookmarked
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }

        return newState
    }
}
