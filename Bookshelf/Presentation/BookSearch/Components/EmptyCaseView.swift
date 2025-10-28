//
//  EmptyCaseView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/28/25.
//

import UIKit
import SnapKit

final class EmptyCaseView: UICollectionViewCell {
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(messageLabel)

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(40)
        }
    }

    // MARK: - Configuration
    func configure(image: UIImage?, message: String) {
        imageView.image = image
        messageLabel.text = message
    }
}
