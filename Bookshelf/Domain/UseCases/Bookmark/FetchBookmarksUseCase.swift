//
//  FetchBookmarksUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import RxSwift

protocol FetchBookmarksUseCaseProtocol {
    func execute() -> Observable<[Book]>
}

struct FetchBookmarksUseCase: FetchBookmarksUseCaseProtocol {
    private let repository: BookmarkRepositoryProtocol

    init(repository: BookmarkRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Observable<[Book]> {
        return repository.fetchBookmarks()
    }
}
