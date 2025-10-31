//
//  CheckBookmarkUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import RxSwift

protocol CheckBookmarkUseCaseProtocol {
    func execute(_ book: Book) -> Observable<Bool>
}

struct CheckBookmarkUseCase: CheckBookmarkUseCaseProtocol {
    private let repository: BookmarkRepositoryProtocol

    init(repository: BookmarkRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ book: Book) -> Observable<Bool> {
        return repository.isBookmarked(book)
    }
}
