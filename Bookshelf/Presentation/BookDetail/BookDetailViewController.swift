//
//  BookDetailViewController.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/29/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa

final class BookDetailViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private let imageView = BookDetailImageView()
    private let titleView = BookDetailTitleView()
    private let priceView = BookDetailPriceView()
    private let contentsView = BookDetailContentsView()
    private let infoView = BookDetailInfoView()

    private lazy var bookmarkButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "담기",
            style: .plain,
            target: nil,
            action: nil
        )
        return button
    }()

    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.closeTapped()
            })
        )
        return button
    }()

    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Reactor Binding
    func bind(reactor: BookDetailViewReactor) {
        // Input: 북마크 상태 확인 (뷰가 로드되면 바로 확인)
        Observable.just(Reactor.Action.checkBookmarkStatus)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Input: 북마크 버튼 탭
        bookmarkButton.rx.tap
            .map { Reactor.Action.toggleBookmark }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output: Book 정보로 UI 구성
        reactor.state.map(\.book)
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] book in
                self?.configure(with: book)
            })
            .disposed(by: disposeBag)

        // Output: 북마크 상태에 따른 버튼 UI 변경
        reactor.state.map(\.isBookmarked)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isBookmarked in
                self?.updateBookmarkButton(isBookmarked: isBookmarked)
            })
            .disposed(by: disposeBag)
    }

    private func updateBookmarkButton(isBookmarked: Bool) {
        bookmarkButton.title = isBookmarked ? "담기 취소" : "담기"
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // 네비게이션 바 설정
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = bookmarkButton
        navigationItem.title = "책 정보"

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // 컴포넌트들을 스택뷰에 추가
        [imageView, titleView, priceView, contentsView, infoView]
            .forEach {
                contentStackView.addArrangedSubview($0)
            }

        // Layout
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }

    private func configure(with book: Book) {
        imageView.configure(with: book.thumbnail)
        titleView.configure(title: book.title, author: book.authors.first ?? "")
        priceView.configure(price: book.price, salePrice: book.salePrice)
        contentsView.configure(with: book.contents)

        // 날짜 포맷 변환
        let dateString = formatDate(book.publishedDate)
        infoView.configure(
            publisher: book.publisher,
            date: dateString,
            status: book.status
        )
    }

    private func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy년 M월"
        displayFormatter.locale = Locale(identifier: "ko_KR")

        return displayFormatter.string(from: date)
    }

    private func closeTapped() {
        dismiss(animated: true)
    }
}


private func makeViewController() -> UIViewController {
    let book = Book(
        title: "조종당하는 인간",
        authors: ["김석재"],
        contents: "『조종당하는 인간』은 뇌의 자동반응과 자기통제의 한계를 과학적·심리학적으로 밝힌 책이다. 반복되는 충동, 끊임없는 후회, 멈출 수 없는 습관 속에서 \"왜 나는 스스로를 제어하지 못할까?\" \"왜 자꾸 같은 실수를 반복할까?\" 라는 질문에 실체적 답을 준다.",
        publishedDate: ISO8601DateFormatter().date(from: "2025-07-16T00:00:00+09:00") ?? Date(),
        publisher: "스노우폭스북스P",
        price: 18500,
        salePrice: 16650,
        thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6970949%3Ftimestamp%3D20250802143825"),
        status: "정상판매"
    )

    let viewController = BookDetailViewController()
    let repository = CoreDataBookmarkRepository()
    viewController.reactor = BookDetailViewReactor(
        book: book,
        addBookmarkUseCase: AddBookmarkUseCase(repository: repository),
        removeBookmarkUseCase: RemoveBookmarkUseCase(repository: repository),
        checkBookmarkUseCase: CheckBookmarkUseCase(repository: repository)
    )

    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}

@available(iOS 17.0, *)
#Preview {
    makeViewController()
}
