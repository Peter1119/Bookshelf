//
//  Book.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import Foundation

public struct Book: Hashable, Sendable {
    public let title: String
    public let authors: [String]
    public let contents: String
    public let publishedDate: Date
    public let publisher: String
    public let price: Double
    public let salePrice: Double?
    public let thumbnail: URL?
    public let status: String

    public init(
        title: String,
        authors: [String],
        contents: String,
        publishedDate: Date,
        publisher: String,
        price: Double,
        salePrice: Double?,
        thumbnail: URL?,
        status: String = "정상판매"
    ) {
        self.title = title
        self.authors = authors
        self.contents = contents
        self.publishedDate = publishedDate
        self.publisher = publisher
        self.price = price
        self.salePrice = salePrice
        self.thumbnail = thumbnail
        self.status = status
    }
}

// MARK: - Mock Data
extension Book {
    static let mockData: [Book] = [
        Book(
            title: "미움받을 용기",
            authors: ["기시미 이치로", "고가 후미타케"],
            contents: "인간은 변할 수 있고, 누구나 행복해 질 수 있다. 단 그러기 위해서는 '용기'가 필요하다고 말한 철학자가 있다. 바로 프로이트, 융과 함께 '심리학의 3대 거장'으로 일컬어지고 있는 알프레드 아들러다.",
            publishedDate: ISO8601DateFormatter().date(from: "2014-11-17T00:00:00+09:00") ?? Date(),
            publisher: "인플루엔셜",
            price: 14900,
            salePrice: 13410,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1467038")
        ),
        Book(
            title: "사피엔스",
            authors: ["유발 하라리"],
            contents: "지구상에 존재했던 세 종류의 인간 중 마지막까지 살아남은 호모 사피엔스. 그들은 어떻게 지구의 정복자가 되었을까?",
            publishedDate: ISO8601DateFormatter().date(from: "2015-11-02T00:00:00+09:00") ?? Date(),
            publisher: "김영사",
            price: 19800,
            salePrice: 17820,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1561237")
        ),
        Book(
            title: "코스모스",
            authors: ["칼 세이건"],
            contents: "우주에 대한 인간의 지적 탐구의 역사를 다룬 과학 교양서. 천문학, 물리학, 화학, 생물학을 아우르며 우주와 생명에 대한 경이로운 이야기를 펼쳐낸다.",
            publishedDate: ISO8601DateFormatter().date(from: "2006-12-20T00:00:00+09:00") ?? Date(),
            publisher: "사이언스북스",
            price: 17000,
            salePrice: nil,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F587193")
        ),
        Book(
            title: "클린 코드",
            authors: ["로버트 C. 마틴"],
            contents: "애자일 소프트웨어 장인 정신의 핵심을 다루는 프로그래밍 필독서. 읽기 쉽고 이해하기 쉬운 코드를 작성하는 방법을 알려준다.",
            publishedDate: ISO8601DateFormatter().date(from: "2013-12-24T00:00:00+09:00") ?? Date(),
            publisher: "인사이트",
            price: 32000,
            salePrice: 28800,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1628508")
        ),
        Book(
            title: "스위프트 프로그래밍",
            authors: ["야곰"],
            contents: "Swift 언어의 기본 문법부터 고급 기능까지 체계적으로 학습할 수 있는 완벽한 Swift 입문서.",
            publishedDate: ISO8601DateFormatter().date(from: "2022-04-25T00:00:00+09:00") ?? Date(),
            publisher: "한빛미디어",
            price: 35000,
            salePrice: 31500,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5967868")
        ),
        Book(
            title: "디자인 패턴",
            authors: ["에리히 감마", "리처드 헬름", "랄프 존슨", "존 블리시디스"],
            contents: "소프트웨어 설계에서 자주 발생하는 문제들을 해결하기 위한 재사용 가능한 해결책들을 정리한 고전적인 프로그래밍 서적.",
            publishedDate: ISO8601DateFormatter().date(from: "2015-03-26T00:00:00+09:00") ?? Date(),
            publisher: "한빛미디어",
            price: 45000,
            salePrice: 40500,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F831142")
        ),
        Book(
            title: "해리 포터와 마법사의 돌",
            authors: ["J.K. 롤링"],
            contents: "마법사 소년 해리 포터의 모험을 그린 판타지 소설. 호그와트 마법학교에서 벌어지는 흥미진진한 이야기.",
            publishedDate: ISO8601DateFormatter().date(from: "1999-12-02T00:00:00+09:00") ?? Date(),
            publisher: "문학수첩",
            price: 12000,
            salePrice: 10800,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1291045")
        ),
        Book(
            title: "1984",
            authors: ["조지 오웰"],
            contents: "전체주의 사회를 그린 디스토피아 소설. 빅 브라더의 감시 아래 살아가는 윈스턴 스미스의 이야기.",
            publishedDate: ISO8601DateFormatter().date(from: "2003-07-10T00:00:00+09:00") ?? Date(),
            publisher: "민음사",
            price: 11000,
            salePrice: nil,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F560147")
        ),
        Book(
            title: "아틀라스 쉬러그드",
            authors: ["아인 랜드"],
            contents: "개인주의 철학을 바탕으로 한 거대한 서사시. 사회의 붕괴와 재건을 그린 대작 소설.",
            publishedDate: ISO8601DateFormatter().date(from: "2007-11-15T00:00:00+09:00") ?? Date(),
            publisher: "청림출판",
            price: 28000,
            salePrice: 25200,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1267988")
        ),
        Book(
            title: "데미안",
            authors: ["헤르만 헤세"],
            contents: "한 소년의 성장과 자아 찾기를 그린 성장소설. 선악의 이분법을 넘어선 인간 본성에 대한 탐구.",
            publishedDate: ISO8601DateFormatter().date(from: "2002-01-20T00:00:00+09:00") ?? Date(),
            publisher: "민음사",
            price: 9500,
            salePrice: 8550,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F527421")
        ),
        Book(
            title: "어린 왕자",
            authors: ["생텍쥐페리"],
            contents: "사막에 불시착한 비행사가 만난 어린 왕자의 이야기. 순수함과 사랑에 대한 철학적 동화.",
            publishedDate: ISO8601DateFormatter().date(from: "2000-03-20T00:00:00+09:00") ?? Date(),
            publisher: "문학동네",
            price: 10000,
            salePrice: 9000,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F511613")
        ),
        Book(
            title: "총, 균, 쇠",
            authors: ["재레드 다이아몬드"],
            contents: "인류 문명의 발전 과정을 지리적, 환경적 요인으로 설명한 역사서.",
            publishedDate: ISO8601DateFormatter().date(from: "2005-12-01T00:00:00+09:00") ?? Date(),
            publisher: "문학사상",
            price: 24000,
            salePrice: 21600,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F664298")
        ),
        Book(
            title: "호모 데우스",
            authors: ["유발 하라리"],
            contents: "인류의 미래를 예측한 책. 인공지능과 생명공학이 인간을 어떻게 변화시킬 것인가?",
            publishedDate: ISO8601DateFormatter().date(from: "2017-05-15T00:00:00+09:00") ?? Date(),
            publisher: "김영사",
            price: 21000,
            salePrice: 18900,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F3315498")
        ),
        Book(
            title: "82년생 김지영",
            authors: ["조남주"],
            contents: "평범한 여성 김지영의 일생을 통해 한국 사회의 성차별 문제를 다룬 소설.",
            publishedDate: ISO8601DateFormatter().date(from: "2016-10-14T00:00:00+09:00") ?? Date(),
            publisher: "민음사",
            price: 13800,
            salePrice: 12420,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F3028311")
        ),
        Book(
            title: "정의란 무엇인가",
            authors: ["마이클 샌델"],
            contents: "하버드대 철학 강의. 정의와 도덕에 대한 근본적인 질문들을 탐구한다.",
            publishedDate: ISO8601DateFormatter().date(from: "2010-05-15T00:00:00+09:00") ?? Date(),
            publisher: "김영사",
            price: 15000,
            salePrice: nil,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1283774")
        ),
        Book(
            title: "연금술사",
            authors: ["파울로 코엘료"],
            contents: "양치기 소년 산티아고가 자신의 꿈을 찾아 떠나는 여정을 그린 우화적 소설.",
            publishedDate: ISO8601DateFormatter().date(from: "2001-11-30T00:00:00+09:00") ?? Date(),
            publisher: "문학동네",
            price: 11000,
            salePrice: 9900,
            thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F466133")
        )
    ]
}
