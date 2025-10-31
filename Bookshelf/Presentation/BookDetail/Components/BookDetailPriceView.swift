//
//  BookDetailPriceView.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/29/25.
//

import UIKit
import SnapKit

final class BookDetailPriceView: UIView {
    private let salePriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemRed
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            salePriceLabel, priceLabel, discountLabel
        ])
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(price: Double, salePrice: Double?) {
        if let salePrice = salePrice {
            // 할인가가 있는 경우
            salePriceLabel.text = "\(Int(salePrice).formatted())원"

            let attributedString = NSAttributedString(
                string: "\(Int(price).formatted())원",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            priceLabel.attributedText = attributedString

            let discount = Int((price - salePrice) / price * 100)
            discountLabel.text = "(\(discount)% 할인)"

            // 모두 표시
            salePriceLabel.isHidden = false
            priceLabel.isHidden = false
            discountLabel.isHidden = false
        } else {
            // 할인가가 없는 경우 (정가만 표시)
            salePriceLabel.text = "\(Int(price).formatted())원"

            // 정가 라벨과 할인 라벨 숨김
            priceLabel.isHidden = true
            discountLabel.isHidden = true
        }
    }
}

private enum PreviewPriceView {
    static func makeView() -> UIView {
        let view = BookDetailPriceView()
        view.configure(price: 18000, salePrice: 10800)
        return view
    }
}

@available(iOS 17.0, *)
#Preview {
    PreviewPriceView.makeView()
}
