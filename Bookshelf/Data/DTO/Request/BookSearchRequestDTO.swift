//
//  BookSearchRequestDTO.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/28/25.
//

import Foundation

struct BookSearchRequestDTO: Encodable {
    enum SearchSort: String, Encodable {
        case accuracy
        case latest
    }
    
    enum Target: String, Encodable {
        case title
        case isbn
        case publisher
        case person
    }
    let query: String
    let page: Int
    let sort: SearchSort? = .accuracy
    let size: Int = 20
    let target: Target = .title
}
