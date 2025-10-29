//
//  SearchBookCardView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import UIKit
import SnapKit

final class SearchBookCardView: UICollectionViewCell {
    // MARK: - UI Components
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 1
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill  // 가로 가득 채우기
        return stack
    }()
    
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill  // 가로 가득 채우기
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 0, right: 8)
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

        stackView.addArrangedSubview(thumbnailImageView)
        stackView.addArrangedSubview(textStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(authorLabel)

        // 이미지 비율 고정 (3:4)
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(thumbnailImageView.snp.height).multipliedBy(3.0/4.0)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 셀 배경 설정
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
    }
    
    // MARK: - Configuration
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.first ?? ""
        
        guard let url = book.thumbnail else {
            thumbnailImageView.image = UIImage(systemName: "book.fill")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)
                await MainActor.run {
                    self.thumbnailImageView.image = image
                }
            } catch {
                await MainActor.run {
                    thumbnailImageView.image = UIImage(systemName: "book.fill")
                }
            }
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
    }
}
