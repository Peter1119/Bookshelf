//
//  BookDetailContentsView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/29/25.
//

import UIKit
import SnapKit

final class BookDetailContentsView: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "📝 책 소개"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let contentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 3  // 초기 상태는 3줄만 표시
        return label
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.contentHorizontalAlignment = .trailing
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.toggleExpand()
        }), for: .touchUpInside)
        return button
    }()

    private var isExpanded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)

        // StackView에 순서대로 추가
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentsLabel)
        stackView.addArrangedSubview(moreButton)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 버튼 오른쪽 정렬
        moreButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
    }

    func configure(with contents: String) {
        contentsLabel.text = contents
    }

    private func toggleExpand() {
        isExpanded.toggle()

        self.contentsLabel.numberOfLines = self.isExpanded ? 0 : 3
        self.moreButton.setTitle(self.isExpanded ? "접기" : "더보기", for: .normal)
    }
}


private enum PreviewContentsView {
    static func makeView() -> UIView {
        let view = BookDetailContentsView()
        view.configure(with: "보잘것없는 대상들과 손잡고 절제된 언어로 삶의 이면을 그려내는 시인 김명수의 아홉번째 시집 『곡옥』. 시인은 보이는 번듯함에 가려 그늘진 곳에서만 묵묵히 자리를 지키고 있는 미물들의 이름을 불러낸다. 표제작인 '곡옥'을 시작으로 '낙과', '노굿 일어, 희미한 노굿 일어', '서풍에게', '당신은 또 이렇게 말하지요', '빙어' 등이 수록되어 있다.")
        return view
    }
}

@available(iOS 17.0, *)
#Preview {
    PreviewContentsView.makeView()
}
