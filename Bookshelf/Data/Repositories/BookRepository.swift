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

    public func fetchRecentBooks() -> Observable<[Book]> {
        return .just([])
    }

    public func saveRecentBook(_ book: Book) -> Observable<Void> {
        return .just(())
    }
}

public struct MockBookRepository: BookRepositoryProtocol {
    public func fetchRecentBooks() -> Observable<[Book]> {
        // Mock 최근 본 책 5개 반환
        return .just(Array(Book.mockData.prefix(5)))
    }

    public func saveRecentBook(_ book: Book) -> Observable<Void> {
        return .just(())
    }

    public func searchBooks(query: String, page: Int = 1) -> Observable<BookSearchResult> {
        return .just(BookSearchResult(books: Book.mockData, isEnd: false))
//        // 검색어가 비어있으면 빈 배열 반환
//        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            return .just([])
//        }
//        
//        // 랜덤하게 데이터 필터링 및 변형
//        let filteredBooks = filterBooksRandomly(query: query, from: Book.mockData)
//        let randomizedBooks = randomizeBookData(filteredBooks)
//        
//        // 0.5 ~ 1.5초의 랜덤한 지연 시간으로 네트워크 호출 시뮬레이션
//        let delay = Double.random(in: 0.5...1.5)
//        
//        return Observable.just(randomizedBooks)
//            .delay(.milliseconds(Int(delay * 1000)), scheduler: MainScheduler.instance)
    }
    
    private func filterBooksRandomly(query: String, from books: [Book]) -> [Book] {
        let lowercaseQuery = query.lowercased()
        
        // 제목이나 작가명에 검색어가 포함된 책들을 찾기
        var matchingBooks = books.filter { book in
            book.title.lowercased().contains(lowercaseQuery) ||
            book.authors.joined(separator: " ").lowercased().contains(lowercaseQuery) ||
            book.contents.lowercased().contains(lowercaseQuery)
        }
        
        // 검색 결과가 없으면 랜덤하게 몇 개의 책을 추가 (검색 시스템의 추천 기능 시뮬레이션)
        if matchingBooks.isEmpty {
            let randomCount = Int.random(in: 1...3)
            matchingBooks = Array(books.shuffled().prefix(randomCount))
        }
        
        // 결과를 랜덤하게 섞고 개수도 랜덤하게 제한
        let resultCount = Int.random(in: 1...min(matchingBooks.count, 7))
        return Array(matchingBooks.shuffled().prefix(resultCount))
    }
    
    private func randomizeBookData(_ books: [Book]) -> [Book] {
        return books.map { originalBook in
            // 20% 확률로 가격을 약간 변경
            let shouldModifyPrice = Int.random(in: 1...5) == 1
            let newPrice = shouldModifyPrice ? 
                originalBook.price + Double.random(in: -2000...2000) : originalBook.price
            
            // 30% 확률로 할인가 추가/변경
            let shouldModifyDiscount = Int.random(in: 1...10) <= 3
            let newSalePrice: Double?
            
            if shouldModifyDiscount {
                if originalBook.salePrice == nil {
                    // 할인가가 없었다면 10-30% 할인 추가
                    let discountRate = Double.random(in: 0.1...0.3)
                    newSalePrice = newPrice * (1 - discountRate)
                } else {
                    // 기존 할인가 약간 변경
                    newSalePrice = originalBook.salePrice! + Double.random(in: -1000...1000)
                }
            } else {
                newSalePrice = originalBook.salePrice
            }
            
            return Book(
                title: originalBook.title,
                authors: originalBook.authors,
                contents: originalBook.contents,
                publishedDate: originalBook.publishedDate,
                publisher: originalBook.publisher,
                price: max(1000, newPrice), // 최소 1000원
                salePrice: newSalePrice.map { max(500, $0) }, // 할인가는 최소 500원
                thumbnail: originalBook.thumbnail
            )
        }
    }
}
