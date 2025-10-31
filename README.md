# Bookshelf

책 검색 및 관리 iOS 앱

## 기능

- 책 검색
- 책 상세 정보 확인
- 북마크 저장
- 최근 본 책 (최대 10개)
- 북마크 편집 및 삭제

## 기술 스택

- **언어**: Swift
- **아키텍처**: ReactorKit (단방향 데이터 플로우)
- **반응형**: RxSwift, RxCocoa
- **데이터 저장**: CoreData
- **네트워크**: URLSession
- **UI**: UIKit, SnapKit
- **네비게이션**: Coordinator 패턴

## 프로젝트 구조

```
Bookshelf/
├── Application/           # 앱 진입점
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Domain/               # 비즈니스 로직
│   ├── Entities/        # 도메인 모델
│   ├── Repositories/    # Repository 프로토콜
│   └── UseCases/        # 유즈케이스
│       ├── Book/
│       └── Bookmark/
├── Data/                 # 데이터 레이어
│   ├── Repositories/    # Repository 구현체
│   ├── DataSources/     # 데이터 소스
│   └── CoreData/        # CoreData 스택
├── Presentation/         # UI 레이어
│   ├── Coordinators/    # 화면 전환 관리
│   ├── BookSearch/      # 검색 화면
│   ├── BookDetail/      # 상세 화면
│   └── BookmarkList/    # 북마크 화면
└── Core/                 # 공통 유틸리티
    └── Extensions/
```

## 아키텍처

### Clean Architecture

도메인, 데이터, 프레젠테이션 레이어로 분리하여 각 레이어의 책임을 명확히 구분

### ReactorKit

View와 비즈니스 로직을 분리하고, 단방향 데이터 플로우로 상태 관리를 단순화

- **Action**: 사용자 인터랙션
- **Mutation**: 상태 변경 명령
- **State**: UI 상태
- **Reduce**: 상태 변경 로직

### Coordinator 패턴

화면 전환 로직을 ViewController에서 분리하여 재사용성과 테스트 용이성 향상

### Repository 패턴

데이터 소스를 추상화하여 데이터 출처와 비즈니스 로직 분리

## 주요 컴포넌트

### Coordinators

- `AppCoordinator`: 앱 전체 플로우 관리
- `TabBarCoordinator`: 탭 바 네비게이션 관리
- `BookSearchCoordinator`: 검색 화면 플로우
- `BookmarkCoordinator`: 북마크 화면 플로우

### ViewControllers

- `BookSearchViewController`: 책 검색 및 최근 본 책 표시
- `BookDetailViewController`: 책 상세 정보 및 북마크 기능
- `BookmarkListViewController`: 저장한 책 목록 및 편집

### Reactors

- `BookSearchViewReactor`: 검색 및 최근 본 책 상태 관리
- `BookDetailViewReactor`: 북마크 상태 관리
- `BookmarkListViewReactor`: 북마크 목록 및 삭제 관리

### UseCases

**Book**
- `SearchBookUseCase`: 책 검색
- `FetchRecentBooksUseCase`: 최근 본 책 조회
- `SaveRecentBookUseCase`: 최근 본 책 저장

**Bookmark**
- `AddBookmarkUseCase`: 북마크 추가
- `RemoveBookmarkUseCase`: 북마크 제거
- `FetchBookmarksUseCase`: 북마크 조회
- `CheckBookmarkUseCase`: 북마크 여부 확인

## 데이터 흐름

1. 사용자 인터랙션 → Action
2. Reactor가 Action을 받아 Mutation 생성
3. Mutation이 State를 변경
4. State 변경이 View에 반영
5. UseCase가 Repository를 통해 데이터 처리
6. Repository가 DataSource(API/CoreData)와 통신

## 특징

- CoreData를 사용한 로컬 데이터 영속화
- DiffableDataSource로 안전한 CollectionView 업데이트
- Coordinator 패턴으로 화면 전환 로직 분리
- Repository에서 의존성 재사용으로 메모리 효율성 향상
- @MainActor로 UI 스레드 안전성 보장

## 실행 방법

1. 프로젝트 클론
2. Xcode에서 열기
3. 빌드 및 실행

## 요구사항

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
