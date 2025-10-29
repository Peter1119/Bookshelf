//
//  BookRepositoryProtocol.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation
import RxSwift

public protocol BookRepositoryProtocol {
    func searchBooks(query: String, page: Int) -> Observable<BookSearchResult>
    func fetchRecentBooks() -> Observable<[Book]>
    func saveRecentBook(_ book: Book) -> Observable<Void>
}
