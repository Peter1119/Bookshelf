//
//  BookDataSource.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation
import RxSwift

protocol BookDataSourceProtocol {
    func searchBooks(_ request: BookSearchRequestDTO) -> Observable<BookSearchResponseDTO>
}

struct BookDataSource: BookDataSourceProtocol {
    private let provider: NetworkProvider

    init(provider: NetworkProvider = .default) {
        self.provider = provider
    }

    func searchBooks(_ request: BookSearchRequestDTO) -> Observable<BookSearchResponseDTO> {
        return Observable.create { observer in
            let task = Task {
                do {
                    let response: BookSearchResponseDTO = try await self.provider.request(
                        BookTargetType.search(request)
                    )
                    observer.onNext(response)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}

enum BookTargetType: TargetType {
    case search(BookSearchRequestDTO)
}

extension BookTargetType {
    var baseURL: String {
        return "https://dapi.kakao.com"
    }

    var path: String {
        switch self {
        case .search:
            return "/v3/search/book"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .search:
            return .get
        }
    }

    var headers: HTTPHeaders {
        // TODO: REST_API_KEY를 환경 변수나 Config에서 가져오도록 수정 필요
        return HTTPHeaders([
            "Authorization": "KakaoAK \(APIConfig.kakaoAPIKey)"
        ])
    }

    var parameters: RequestParameter? {
        switch self {
        case .search(let request):
            return .query(request)
        }
    }
}
