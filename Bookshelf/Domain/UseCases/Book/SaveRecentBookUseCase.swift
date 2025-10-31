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
    private let repository: RecentBookRepositoryProtocol

    init(repository: RecentBookRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ book: Book) -> Observable<Void> {
        return repository.saveRecentBook(book)
    }
}
