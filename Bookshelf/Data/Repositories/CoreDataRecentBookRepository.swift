//
//  CoreDataRecentBookRepository.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import CoreData
import Foundation
import RxSwift

final class CoreDataRecentBookRepository: RecentBookRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let maxRecentBooks = 10

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func saveRecentBook(_ book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "CoreDataRecentBookRepository", code: -1))
                return Disposables.create()
            }

            let context = self.coreDataStack.context
            let fetchRequest: NSFetchRequest<RecentBookEntity> = RecentBookEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", book.title)

            do {
                // 이미 존재하는 경우 삭제 (중복 방지)
                let existingBooks = try context.fetch(fetchRequest)
                existingBooks.forEach { context.delete($0) }

                // 새로운 최근 본 책 추가
                _ = RecentBookEntity.from(book: book, context: context)

                // 10개 초과 시 오래된 것 삭제
                let allFetchRequest: NSFetchRequest<RecentBookEntity> = RecentBookEntity.fetchRequest()
                allFetchRequest.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
                let allBooks = try context.fetch(allFetchRequest)

                if allBooks.count > self.maxRecentBooks {
                    let booksToDelete = allBooks.dropFirst(self.maxRecentBooks)
                    booksToDelete.forEach { context.delete($0) }
                }

                try context.save()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func fetchRecentBooks() -> Observable<[Book]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "CoreDataRecentBookRepository", code: -1))
                return Disposables.create()
            }

            let context = self.coreDataStack.context
            let fetchRequest: NSFetchRequest<RecentBookEntity> = RecentBookEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
            fetchRequest.fetchLimit = self.maxRecentBooks

            do {
                let results = try context.fetch(fetchRequest)
                let books = results.map { $0.toBook() }
                observer.onNext(books)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }
}

public struct MockRecentBookRepository: RecentBookRepositoryProtocol {
    func fetchRecentBooks() -> Observable<[Book]> {
        return .just(Book.mockData)
    }
    
    func saveRecentBook(_ book: Book) -> Observable<Void> {
        return .just(())
    }
}
