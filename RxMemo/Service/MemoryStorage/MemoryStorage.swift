//
//  MemoryStorage.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift

// 메모리에 메모를 저장하는 클래스
class MemoryStorage: MemoStorageType {
    
    // 메모를 저장할 배열
    // 클래스 외부에서 배열에 직접 접근할 필요가 없기 때문에 private으로 선언
    private var list = [
        Memo(content: "Hello, RxSwift", insertDate: Date().addingTimeInterval(-10)),
        Memo(content: "Lorem Ipsum", insertDate: Date().addingTimeInterval(-20))
    ]
    // 배열은 Observable을 통해 외부로 공개됨
    // 이 Observable은 배열의 상태가 업데이트 되면 새로운 Next 이벤트를 방출해야 함
    // 그냥 Observable 형식으로 만들어버리면 이런 게 불가능함
    // 그래서 Subject로 만들어야됨
    // 초기에 더미데이터를 표시해야 돼서 BehaviorSubject로 만들기
    private lazy var store = BehaviorSubject<[Memo]>(value: list)
    // 기본값을 list 배열로 선언하기 위해서 lazy로 선언
    // subject 역시 외부에서 직접 접근할 필요가 없기 때문에 private
    
    
    @discardableResult
    func createMemo(content: String) -> Observable<Memo> {
        // 새로운 메모를 생성하고 배열에 추가
        let memo = Memo(content: content)
        list.insert(memo, at: 0)
        
        // subject에서 새로운 next 이벤트를 방출
        store.onNext(list)
        
        // 새로운 memo를 방출하는 Observable을 리턴
        return Observable.just(memo)
    }
    
    
    
    // 클래스 외부에서는 항상 이 메소드를 통해서 subject에 접근
    @discardableResult
    func memoList() -> Observable<[Memo]> {
        return store
    }
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo> {
        let updated = Memo(original: memo, updateContent: content)
        
        if let index = list.firstIndex(where: { $0 == memo }) {
            list.remove(at: index)
            list.insert(updated, at: index)
        }
        
        // subject에서 새로운 next 이벤트를 방출
        store.onNext(list)
        
        // 업데이트된 memo를 방출하는 Observable을 리턴
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo> {
        if let index = list.firstIndex(where: { $0 == memo }) {
            list.remove(at: index)
        }
        
        // subject에서 새로운 next 이벤트를 방출
        store.onNext(list)
        
        // 삭제된 memo를 방출하는 Observable을 리턴
        return Observable.just(memo)
    }
}


// 구현한 코드를 보면 배열을 변경한 다음에 subject에서 새로운 Next 이벤트를 방출하는 패턴으로 구현
// 나중에 subject를 tableView와 바인딩할 건데 이렇게 새로운 배열을 계속해서 방출해야 tableView가 정상적으로 업데이트됨
// Cocoa처럼 reloadData()를 호출하는 방식으로는 tableView가 업데이트되지 않음
