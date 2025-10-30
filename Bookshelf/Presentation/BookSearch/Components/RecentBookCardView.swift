//
//  RecentBookCardView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import UIKit
import SnapKit

final class RecentBookCardView: UICollectionViewCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // cornerRadius 적용
        thumbnailImageView.layer.cornerRadius = 80 / 2
        thumbnailImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
    
    private func setupUI() {
        self.contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configure(with imageURL: URL?) {
        guard let imageURL else {
            thumbnailImageView.image = UIImage(systemName: "book.fill")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
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
}
