//
//  BookmarkEntity+Extensions.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import CoreData
import Foundation

extension BookmarkEntity {
    // Book -> BookmarkEntity 변환
    static func from(book: Book, context: NSManagedObjectContext) -> BookmarkEntity {
        let entity = BookmarkEntity(context: context)
        entity.title = book.title
        entity.authors = book.authors.joined(separator: ",") // 배열을 문자열로
        entity.contents = book.contents
        entity.publishedDate = book.publishedDate
        entity.publisher = book.publisher
        entity.price = book.price
        entity.salePrice = book.salePrice ?? 0
        entity.thumbnailURL = book.thumbnail?.absoluteString
        entity.status = book.status
        entity.createdAt = Date()
        return entity
    }

    // BookmarkEntity -> Book 변환
    func toDomain() -> Book {
        return Book(
            title: title ?? "",
            authors: (authors ?? "").split(separator: ",").map { String($0) },
            contents: contents ?? "",
            publishedDate: publishedDate ?? Date(),
            publisher: publisher ?? "",
            price: price,
            salePrice: salePrice == 0 ? nil : salePrice,
            thumbnail: thumbnailURL != nil ? URL(string: thumbnailURL!) : nil,
            status: status ?? ""
        )
    }
}
