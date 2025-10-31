//
//  RecentBookRepositoryProtocol.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/31/25.
//

import Foundation
import RxSwift

protocol RecentBookRepositoryProtocol {
    func fetchRecentBooks() -> Observable<[Book]>
    func saveRecentBook(_ book: Book) -> Observable<Void>
}
