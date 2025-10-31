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
    weak var coordinator: BookmarkCoordinator?

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

    private let emptyView = BookmarkEmptyView()

    private lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "편집",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        return button
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Book>!
    private var isEditMode = false
    private var selectedBooks: Set<Book> = []

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
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] books in
                guard let self = self, self.dataSource != nil else { return }
                self.updateSnapshot(with: books)
                self.updateCountLabel(count: books.count)

                // 편집 모드에서 모든 책이 삭제되면 편집 모드 해제
                if self.isEditMode && books.isEmpty {
                    self.isEditMode = false
                    self.selectedBooks.removeAll()
                    self.editButton.title = "편집"
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.countLabel)
                }
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

        // 네비게이션 바 버튼 설정
        editButton.isEnabled = false // 초기 상태는 비활성화
        navigationItem.leftBarButtonItem = editButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: countLabel)

        view.addSubview(collectionView)
        view.addSubview(emptyView)

        collectionView.register(BookmarkBookCell.self)
        collectionView.allowsMultipleSelection = true

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func updateCountLabel(count: Int) {
        countLabel.text = "총 \(count)권"
        editButton.isEnabled = count > 0
        emptyView.isHidden = count > 0
    }

    @objc private func editButtonTapped() {
        isEditMode.toggle()
        selectedBooks.removeAll()

        if isEditMode {
            editButton.title = "완료"
            // 삭제 버튼 추가
            let deleteButton = UIBarButtonItem(
                title: "삭제",
                style: .plain,
                target: self,
                action: #selector(deleteButtonTapped)
            )
            deleteButton.tintColor = .systemRed
            navigationItem.rightBarButtonItems = [deleteButton]
        } else {
            editButton.title = "편집"
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: countLabel)
        }

        // 모든 셀의 선택 상태 초기화
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }

        // DiffableDataSource 사용 시 snapshot을 다시 apply
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections(snapshot.sectionIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @objc private func deleteButtonTapped() {
        guard !selectedBooks.isEmpty else { return }

        let alert = UIAlertController(
            title: "삭제 확인",
            message: "\(selectedBooks.count)권의 책을 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteSelectedBooks()
        })

        present(alert, animated: true)
    }

    private func deleteSelectedBooks() {
        selectedBooks.forEach { book in
            reactor?.action.onNext(.deleteBookmark(book))
        }
        selectedBooks.removeAll()

        // 편집 모드 해제는 bind에서 books.isEmpty일 때 자동으로 처리됨
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, book in
                let cell: BookmarkBookCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: book)

                // 편집 모드일 때 체크마크 표시
                let isEditMode = self?.isEditMode ?? false
                let isSelected = self?.selectedBooks.contains(book) ?? false
                cell.setEditMode(isEditMode, isSelected: isSelected)

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
        coordinator?.showBookDetail(book: book)
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
        guard let book = dataSource.itemIdentifier(for: indexPath) else { return }

        if isEditMode {
            // 편집 모드: 선택/해제
            if selectedBooks.contains(book) {
                selectedBooks.remove(book)
            } else {
                selectedBooks.insert(book)
            }

            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems([book])
            dataSource.apply(snapshot, animatingDifferences: false)
        } else {
            // 일반 모드: 상세 화면으로 이동
            reactor?.action.onNext(.selectBook(book))
        }
    }
}

private func makeViewController() -> UIViewController {
    let viewController = BookmarkListViewController()
    let repository = CoreDataBookmarkRepository()
    viewController.reactor = BookmarkListViewReactor(
        fetchBookmarksUseCase: FetchBookmarksUseCase(repository: repository),
        removeBookmarkUseCase: RemoveBookmarkUseCase(repository: repository)
    )
    return UINavigationController(rootViewController: viewController)
}

@available(iOS 17.0, *)
#Preview {
    makeViewController()
}
