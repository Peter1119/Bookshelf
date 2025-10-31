//
//  BookmarkRepositoryProtocol.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import Foundation
import RxSwift

public protocol BookmarkRepositoryProtocol {
    func addBookmark(_ book: Book) -> Observable<Void>
    func removeBookmark(_ book: Book) -> Observable<Void>
    func fetchBookmarks() -> Observable<[Book]>
    func isBookmarked(_ book: Book) -> Observable<Bool>
}
