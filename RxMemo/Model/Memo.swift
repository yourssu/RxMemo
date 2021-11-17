//
//  Memo.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxDataSources
// tableView, collectionView에 바인딩 할 수 있는 dataSource를 제공함
// dataSource에 저장되는 모든 데이터는 반드시 IdentifiableType 프로토콜을 채용해야됨
// IdentifiableType 프로토콜에는 identity 속성이 선언되어 있음
// identity 속성의 형식은 Hashable 프로토콜을 채용한 형식으로 제한되어 있는데
// 메모 구조체에 있느 identity 속성은 형식이 String으로 선언되어 있는데 String은 Hashable 프로토콜을 채용한 형식이므로
// 프로토콜이 요구하는 모든 사항을 충족시킴

struct Memo: Equatable, IdentifiableType {
    var content: String     // 메모
    var insertDate: Date    // 생성 날짜
    var identity: String    // 메모를 구분할 때 사용되는 속성
    
    // 생성자 추가
    init(content: String, insertDate: Date = Date()) {
        self.content = content
        self.insertDate = insertDate
        self.identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    // 업데이트된 내용으로 새로운 메모 인스턴스를 생성할 때 사용
    init(original: Memo, updateContent: String) {
        self = original
        self.content = updateContent
    }
}
