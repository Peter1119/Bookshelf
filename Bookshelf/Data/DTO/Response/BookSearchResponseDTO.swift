//
//  BookSearchResponseDTO.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/28/25.
//

import Foundation

struct BookSearchResponseDTO: Decodable {
    struct Meta: Decodable {
        let isEnd: Bool
        let pageableCount: Int
        let totalCount: Int
    }

    let meta: Meta
    let documents: [BookResponseDTO]
}

struct BookResponseDTO: Decodable {
    let title: String
    let contents: String
    let url: String
    let isbn: String
    let datetime: String
    let authors: [String]
    let publisher: String
    let translators: [String]
    let price: Int
    let salePrice: Int
    let thumbnail: String
    let status: String
}

extension BookResponseDTO {
    func toDomain() -> Book {
        let dateFormatter = ISO8601DateFormatter()
        let publishedDate = dateFormatter.date(from: datetime) ?? Date()

        let thumbnailURL = URL(string: thumbnail)

        return Book(
            title: title,
            authors: authors,
            contents: contents,
            publishedDate: publishedDate,
            publisher: publisher,
            price: Double(price),
            salePrice: salePrice > 0 ? Double(salePrice) : nil,
            thumbnail: thumbnailURL
        )
    }
}
