//
//  BookmarkEmptyView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/31/25.
//

import UIKit
import SnapKit

final class BookmarkEmptyView: UICollectionReusableView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bookmark.slash")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "담은 책이 없습니다"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "마음에 드는 책을 담아보세요"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
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
        addSubview(stackView)

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(descriptionLabel)

        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
