//
//  APIConfig.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/28/25.
//

import Foundation

enum APIConfig {
    static var kakaoAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String else {
            fatalError("KAKAO_API_KEY not found in Info.plist")
        }
        return key
    }
}
