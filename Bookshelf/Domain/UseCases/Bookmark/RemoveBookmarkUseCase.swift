//
//  RemoveBookmarkUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import RxSwift

protocol RemoveBookmarkUseCaseProtocol {
    func execute(_ book: Book) -> Observable<Void>
}

struct RemoveBookmarkUseCase: RemoveBookmarkUseCaseProtocol {
    private let repository: BookmarkRepositoryProtocol

    init(repository: BookmarkRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ book: Book) -> Observable<Void> {
        return repository.removeBookmark(book)
    }
}
