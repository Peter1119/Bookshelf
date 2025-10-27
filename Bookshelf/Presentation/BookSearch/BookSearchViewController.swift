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

final class BookSearchViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    private let searchBar: UISearchBar = {
        let result = UISearchBar()
        result.placeholder = "책 제목을 입력하세요"
        return result
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        return view
    }()

    private var recentBooks: [Book] = []
    private var searchResults: [Book] = []
    
    enum Section: Int, CaseIterable {
        case recent      // 가로 스크롤
        case search      // 세로 스크롤
        
        var title: String {
            switch self {
            case .recent: return "최근 본 책"
            case .search: return "검색 결과"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
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
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output: State의 recentBooks 변화 감지
        reactor.state.map(\.recentBooks)
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                self?.recentBooks = books
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        // Output: State의 searchResults 변화 감지
        reactor.state.map(\.searchResults)
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                self?.searchResults = books
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(searchBar)

        searchBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Compositional Layout
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .recent:
                return self.createRecentSection()  // 가로 스크롤
            case .search:
                return self.createSearchSection(environment: environment)  // 그리드
            }
        }
    }
    
    // 최근 본 책 - 가로 스크롤
    private func createRecentSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous  // 가로 스크롤
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // 검색 결과 - 그리드 (2개 고정)
    private func createSearchSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 2개 컬럼으로 고정
        let columnCount = 2

        // Item: 각 셀
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),  // count로 자동 분할
            heightDimension: .estimated(200)        // 동적 높이
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

        // Group: 가로로 columnCount개씩 배치
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: columnCount  // 이 count가 자동으로 너비 분할
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 20, trailing: 8)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        // Cell 등록
        collectionView.register(RecentBookCardView.self)
        collectionView.register(SearchBookCardView.self)
        
        // Header 등록
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )

        collectionView.dataSource = self
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension BookSearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .recent:
            return recentBooks.count
        case .search:
            return searchResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .recent:
            let cell: RecentBookCardView = collectionView.dequeueReusableCell(for: indexPath)
            let book = recentBooks[indexPath.item]
            cell.configure(with: book.thumbnail)
            return cell
            
        case .search:
            let cell: SearchBookCardView = collectionView.dequeueReusableCell(for: indexPath)
            let book = searchResults[indexPath.item]
            cell.configure(with: book)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let section = Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        let header: SectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        header.configure(title: section.title)
        
        return header
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
