//
//  AddBookmarkUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import RxSwift

protocol AddBookmarkUseCaseProtocol {
    func execute(_ book: Book) -> Observable<Void>
}

struct AddBookmarkUseCase: AddBookmarkUseCaseProtocol {
    private let repository: BookmarkRepositoryProtocol

    init(repository: BookmarkRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ book: Book) -> Observable<Void> {
        return repository.addBookmark(book)
    }
}
