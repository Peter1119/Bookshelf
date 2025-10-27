//
//  FetchRecentBooksUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation
import RxSwift

protocol FetchRecentBooksUseCaseProtocol {
    func execute() -> Observable<[Book]>
}

final class FetchRecentBooksUseCase: FetchRecentBooksUseCaseProtocol {
    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Observable<[Book]> {
        return repository.fetchRecentBooks()
    }
}
