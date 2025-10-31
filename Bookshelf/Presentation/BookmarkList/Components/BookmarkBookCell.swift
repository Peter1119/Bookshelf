//
//  BookmarkBookCell.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import UIKit
import SnapKit

final class BookmarkBookCell: UICollectionViewCell {
    // MARK: - UI Components
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let publisherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        return stack
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private var imageTask: URLSessionDataTask?
    private var isEditMode = false

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
        contentView.backgroundColor = .systemBackground

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(checkmarkImageView)

        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(authorLabel)
        infoStackView.addArrangedSubview(publisherLabel)

        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(90)
        }

        infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            make.trailing.equalTo(checkmarkImageView.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }

    // MARK: - Configure
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        publisherLabel.text = book.publisher

        // 이미지 로드
        thumbnailImageView.image = UIImage(systemName: "book.closed")
        thumbnailImageView.tintColor = .systemGray3

        if let thumbnailURL = book.thumbnail {
            loadImage(from: thumbnailURL)
        }
    }

    func setEditMode(_ isEditMode: Bool, isSelected: Bool) {
        self.isEditMode = isEditMode
        checkmarkImageView.isHidden = !isEditMode

        if isEditMode {
            checkmarkImageView.image = isSelected
                ? UIImage(systemName: "checkmark.circle.fill")
                : UIImage(systemName: "circle")
        }
    }

    private func loadImage(from url: URL) {
        imageTask?.cancel()

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                return
            }

            DispatchQueue.main.async {
                self.thumbnailImageView.image = image
                self.thumbnailImageView.tintColor = nil
            }
        }
        imageTask?.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumbnailImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        publisherLabel.text = nil
        checkmarkImageView.isHidden = true
        isEditMode = false
    }
}
