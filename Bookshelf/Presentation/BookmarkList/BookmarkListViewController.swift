//
//  BookmarkListViewController.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import UIKit
import ReactorKit
import RxCocoa
import SnapKit

@MainActor
final class BookmarkListViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .systemBackground
        view.delegate = self
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Book>!

    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()

        // dataSource 초기화 후 북마크 로드
        reactor?.action.onNext(.loadBookmarks)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 다시 나타날 때마다 최신 목록 로드
        reactor?.action.onNext(.loadBookmarks)
    }

    func bind(reactor: BookmarkListViewReactor) {
        // Output: 북마크 목록 업데이트
        reactor.state.map(\.bookmarks)
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                guard let self = self, self.dataSource != nil else { return }
                self.updateSnapshot(with: books)
                self.updateCountLabel(count: books.count)
            })
            .disposed(by: disposeBag)

        // Output: 책 선택 시 상세 화면 표시
        reactor.state.compactMap(\.selectedBook)
            .distinctUntilChanged { $0.title == $1.title }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] book in
                self?.presentBookDetail(book: book)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        title = "담은 책"
        view.backgroundColor = .systemBackground

        // 네비게이션 바 오른쪽에 총 권수 라벨 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: countLabel)

        view.addSubview(collectionView)

        collectionView.register(BookmarkBookCell.self, forCellWithReuseIdentifier: "BookmarkCell")

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func updateCountLabel(count: Int) {
        countLabel.text = "총 \(count)권"
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, book in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "BookmarkCell",
                    for: indexPath
                ) as! BookmarkBookCell
                cell.configure(with: book)
                return cell
            }
        )
    }

    private func updateSnapshot(with books: [Book]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Book>()
        snapshot.appendSections([.main])
        snapshot.appendItems(books, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
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
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

extension BookmarkListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 110)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = dataSource.itemIdentifier(for: indexPath),
              let reactor = reactor else { return }
        reactor.action.onNext(.selectBook(book))
    }
}

private func makeViewController() -> UIViewController {
    let viewController = BookmarkListViewController()
    let repository = CoreDataBookmarkRepository()
    viewController.reactor = BookmarkListViewReactor(
        fetchBookmarksUseCase: FetchBookmarksUseCase(repository: repository)
    )
    return UINavigationController(rootViewController: viewController)
}

@available(iOS 17.0, *)
#Preview {
    makeViewController()
}
