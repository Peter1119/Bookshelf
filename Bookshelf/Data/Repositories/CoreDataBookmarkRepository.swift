//
//  CoreDataBookmarkRepository.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import CoreData
import Foundation
import RxSwift

final class CoreDataBookmarkRepository: BookmarkRepositoryProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func addBookmark(_ book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "CoreDataBookmarkRepository", code: -1))
                return Disposables.create()
            }

            let context = self.coreDataStack.context
            _ = BookmarkEntity.from(book: book, context: context)

            do {
                try context.save()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func removeBookmark(_ book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "CoreDataBookmarkRepository", code: -1))
                return Disposables.create()
            }

            let context = self.coreDataStack.context
            let fetchRequest: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", book.title)

            do {
                let results = try context.fetch(fetchRequest)
                results.forEach { context.delete($0) }
                try context.save()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func fetchBookmarks() -> Observable<[Book]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "CoreDataBookmarkRepository", code: -1))
                return Disposables.create()
            }

            let context = self.coreDataStack.context
            let fetchRequest: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            do {
                let results = try context.fetch(fetchRequest)
                let books = results.map { $0.toDomain() }
                observer.onNext(books)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func isBookmarked(_ book: Book) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "CoreDataBookmarkRepository", code: -1))
                return Disposables.create()
            }

            let context = self.coreDataStack.context
            let fetchRequest: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", book.title)

            do {
                let count = try context.count(for: fetchRequest)
                observer.onNext(count > 0)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }
}
