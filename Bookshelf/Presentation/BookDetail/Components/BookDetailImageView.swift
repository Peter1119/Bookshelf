//
//  BookDetailImageView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/29/25.
//

import UIKit
import SnapKit

final class BookDetailImageView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()  // 중앙 정렬
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)  // 화면 가로의 50%
            make.height.equalTo(imageView.snp.width).multipliedBy(1.4)  // 3:4 비율 (책 비율)
        }
    }
    
    func configure(with url: URL?) {
        guard let url else { return }
        
        Task {
            guard
                let (data, _) = try? await URLSession.shared.data(for: URLRequest(url: url)),
                let image = UIImage(data: data)
            else {
                return
            }
            await MainActor.run {
                self.imageView.image = image
            }
        }
    }
}
