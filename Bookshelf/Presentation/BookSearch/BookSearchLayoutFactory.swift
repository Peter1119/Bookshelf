//
//  BookSearchLayoutFactory.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import UIKit


enum BookSearchItem: Hashable, Sendable {
    case recentBook(Book)
    case searchBook(Book)
    case empty
}


enum BookSearchSection: Int, CaseIterable, Hashable, Sendable {
    case recent
    case search

    var title: String {
        switch self {
        case .recent: return "최근 본 책"
        case .search: return "검색 결과"
        }
    }
}


enum BookSearchLayoutFactory {


    // MARK: - Layout 생성
    static func createLayout(shouldShowEmptyView: @escaping () -> Bool) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = BookSearchSection(rawValue: sectionIndex) else { return nil }

            switch section {
            case .recent:
                return createRecentSection()
            case .search:
                // 검색 결과가 비어있으면 Empty 레이아웃 사용
                if shouldShowEmptyView() {
                    return createEmptySection()
                }
                return createSearchSection(environment: environment)
            }
        }
    }

    // MARK: - 최근 본 책 Section (가로 스크롤)
    private static func createRecentSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )

        // Header
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    // MARK: - 검색 결과 Section (그리드)
    private static func createSearchSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 화면 너비에 따라 열 개수 결정
        let columnCount: Int
        if environment.container.effectiveContentSize.width > 800 {
            columnCount = 4  // 가로 모드
        } else {
            columnCount = 2  // 세로 모드
        }

        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: columnCount
        )
        group.interItemSpacing = .fixed(16)

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        // Header
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    // MARK: - Empty Section (전체 너비)
    private static func createEmptySection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        // Header
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    // MARK: - Section Header
    private static func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
