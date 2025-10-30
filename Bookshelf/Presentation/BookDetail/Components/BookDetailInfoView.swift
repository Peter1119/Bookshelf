//
//  BookDetailInfoView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/29/25.
//

import UIKit
import SnapKit

final class BookDetailInfoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ℹ️ 상세정보"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(stackView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure(
        publisher: String,
        date: String,
        status: String
    ) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let publisherRow = makeInfoRow(
            icon: "🏢",
            title: "출판사",
            value: publisher
        )
        let dateRow = makeInfoRow(
            icon: "📅",
            title: "출판일",
            value: date
        )
        let statusRow = makeInfoRow(
            icon: "✅",
            title: "상태",
            value: status
        )

        [publisherRow, makeDivider(), dateRow, makeDivider(), statusRow]
            .forEach { stackView.addArrangedSubview($0) }
    }

    private func makeInfoRow(
        icon: String,
        title: String,
        value: String
    ) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center
        container.distribution = .fill

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 16)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .systemGray

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.textAlignment = .right

        container.addArrangedSubview(iconLabel)
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(spacer)
        container.addArrangedSubview(valueLabel)

        // 아이콘과 제목의 크기를 고정
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        return container
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return divider
    }
}


private enum PreviewInfoView {
    static func makeView() -> UIView {
        let view = BookDetailInfoView()
        view.configure(
            publisher: "스노우폭스북스P",
            date: "2025년 7월",
            status: "정상판매"
        )
        return view
    }
}

@available(iOS 17.0, *)
#Preview {
    PreviewInfoView.makeView()
}
