//
//  Memo.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation

struct Memo: Equatable {
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
