//
//  SaveRecentBookUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import RxSwift

protocol SaveRecentBookUseCaseProtocol {
    func execute(_ book: Book) -> Observable<Void>
}

struct SaveRecentBookUseCase: SaveRecentBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ book: Book) -> Observable<Void> {
        return repository.saveRecentBook(book)
    }
}
