//
//  BookRepository.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation
import RxSwift

public struct BookRepository: BookRepositoryProtocol {
    private let dataSource: BookDataSourceProtocol
    
    init(dataSource: BookDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    public func searchBooks(query: String, page: Int) -> Observable<BookSearchResult> {
        return dataSource
            .searchBooks(BookSearchRequestDTO(query: query, page: page))
            .map { $0.toDomain() }
    }
}

public struct MockBookRepository: BookRepositoryProtocol {
    public func searchBooks(query: String, page: Int = 1) -> Observable<BookSearchResult> {
        return .just(BookSearchResult(books: Book.mockData, isEnd: false))
    }
}
