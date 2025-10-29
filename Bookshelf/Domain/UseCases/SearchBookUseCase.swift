//
//  SearchBookUseCase.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation
import RxSwift

protocol SearchBookUseCaseProtocol {
    func execute(query: String, page: Int) -> Observable<[Book]>
}

struct SearchBookUseCase: SearchBookUseCaseProtocol {
    private let reporitory: BookRepositoryProtocol
    
    init(reporitory: BookRepositoryProtocol) {
        self.reporitory = reporitory
    }
    
    func execute(query: String, page: Int) -> Observable<[Book]> {
        return reporitory.searchBooks(query: query, page: page)
    }
}

