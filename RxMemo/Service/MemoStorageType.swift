//
//  MemoStorageType.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift

// 기본적인 CRUD를 처리하는 메소드
protocol MemoStorageType {
    
    @discardableResult
    func createMemo(content: String) -> Observable<Memo>
    // 리턴형이 Observable
    // 구독자가 작업 결과를 원하는 방식으로 처리할 수 있게 됨
    // 작업 결과가 필요없는 경우도 있을 수 있어서 메소드에 @discardableResult 특성을 추가함
    
    @discardableResult
    func memoList() -> Observable<[MemoSectionModel]>
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo>
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo>
    
}
