//
//  MemoListViewModel.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift
import RxCocoa

class MemoListViewModel: CommonViewModel {
    // 메모 목록 화면에서 필요한 것은 메모 목록
    // 그래서 tableView와 바인딩할 수 있는 속성을 추가
    // 이 속성은 메모 배열을 방출
    var memoList: Observable<[Memo]> {
        // 저장소에 구현되어 있는 memoList() 메소드를 호출하고 메소드가 리턴하는 Observable을 그대로 리턴
        return storage.memoList()
    }
    
    
}
