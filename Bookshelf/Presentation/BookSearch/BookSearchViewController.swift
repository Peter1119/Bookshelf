//
//  BookSearchViewController.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import UIKit
import ReactorKit
import RxCocoa
import SnapKit

@MainActor
final class BookSearchViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: UICollectionViewDiffableDataSource<BookSearchSection, BookSearchItem>!
    private let searchBar: UISearchBar = {
        let result = UISearchBar()
        result.placeholder = "책 제목을 입력하세요"
        return result
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: BookSearchLayoutFactory.createLayout(shouldShowEmptyView: { [weak self] in
                guard let self = self else { return false }
                return self.searchResults.isEmpty
            })
        )
        view.backgroundColor = .systemBackground
        view.keyboardDismissMode = .onDrag
        return view
    }()

    private var recentBooks: [Book] = []
    private var searchResults: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                switch item {
                case .recentBook(let book):
                    let cell: RecentBookCardView = collectionView.dequeueReusableCell(for: indexPath)
                    
                    cell.configure(with: book.thumbnail)
                    return cell
                case .searchBook(let book):
                    let cell: SearchBookCardView = collectionView.dequeueReusableCell(for: indexPath)
                    cell.configure(with: book)
                    return cell
                case .empty:
                    let cell: EmptyCaseView = collectionView.dequeueReusableCell(for: indexPath)
                    cell.configure(
                        image: UIImage(systemName: "magnifyingglass"),
                        message: "검색 결과가 없습니다"
                    )
                    return cell
                }
            }
        )
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = BookSearchSection(rawValue: indexPath.section) else {
                return nil
            }
            
            let header: SectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            header.configure(title: section.title)
            return header
        }
    }

    func bind(reactor: BookSearchViewReactor) {
        // Input: 최근 본 책 로드
        Observable.just(Reactor.Action.loadRecentBooks)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Input: SearchBar 텍스트를 Reactor Action으로 전달
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .withUnretained(self)
            .filter { owner, event in
                let (_, indexPath) = event
                let lastSectionIndex = owner.collectionView.numberOfSections - 1
                let lastItemIndex = owner.collectionView.numberOfItems(inSection: lastSectionIndex) - 1
                
                return indexPath.section == lastSectionIndex && indexPath.item == lastItemIndex
            }
            .map { _ in Reactor.Action.loadMoreSearchResults }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output: State의 recentBooks 변화 감지
        reactor.state.map(\.recentBooks)
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                self?.recentBooks = books
                self?.updateSnapshot()
            })
            .disposed(by: disposeBag)

        // Output: State의 searchResults 변화 감지
        reactor.state.map(\.searchResults)
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                self?.searchResults = books
                self?.updateSnapshot()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateSnapshot() {
        Task {
            var snapshot = NSDiffableDataSourceSnapshot<BookSearchSection, BookSearchItem>()
            
            snapshot.appendSections([.recent, .search])
            
            let recentItems = recentBooks.map { BookSearchItem.recentBook($0) }
            snapshot.appendItems(recentItems, toSection: .recent)
            
            if searchResults.isEmpty {
                snapshot.appendItems([.empty], toSection: .search)
            } else {
                let searchItems = searchResults.map { BookSearchItem.searchBook($0) }
                snapshot.appendItems(searchItems, toSection: .search)
            }
            await dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(searchBar)

        searchBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - CollectionView Setup

    private func setupCollectionView() {
        view.addSubview(collectionView)

        // Cell 등록
        collectionView.register(RecentBookCardView.self)
        collectionView.register(SearchBookCardView.self)
        collectionView.register(EmptyCaseView.self)

        // Header 등록
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )

        // Cell 선택 처리
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let item = self.dataSource.itemIdentifier(for: indexPath)

                switch item {
                case .recentBook(let book), .searchBook(let book):
                    self.presentBookDetail(book: book)
                case .empty, .none:
                    break
                }
            })
            .disposed(by: disposeBag)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide)
            // 키보드 레이아웃 가이드를 사용하여 자동으로 키보드 회피
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
    }

    private func presentBookDetail(book: Book) {
        let repository = CoreDataBookmarkRepository()
        let detailVC = BookDetailViewController()
        detailVC.reactor = BookDetailViewReactor(
            book: book,
            addBookmarkUseCase: AddBookmarkUseCase(repository: repository),
            removeBookmarkUseCase: RemoveBookmarkUseCase(repository: repository),
            checkBookmarkUseCase: CheckBookmarkUseCase(repository: repository)
        )

        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}

private func makeViewController() -> UIViewController {
    let viewController = BookSearchViewController()
    viewController.reactor = BookSearchViewReactor(
        searchBookUseCase: SearchBookUseCase(reporitory: MockBookRepository()),
        fetchRecentBooksUseCase: FetchRecentBooksUseCase(
            repository: MockBookRepository()
        )
    )
    return viewController
}

@available(iOS 17.0, *)
#Preview {
    makeViewController()
}
