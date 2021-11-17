//
//  MemoDetailViewModel.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class MemoDetailViewModel: CommonViewModel {
    
    // 이전 Scene에서 전달된 메모 저장
    let memo: Memo
    
    
    // 날짜를 문자열로 바꿀 때 사용
    private var formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "Ko_kr")
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()
    
    
    // 메모 내용은 tableView에 표시됨
    // 첫 번째 셀에는 메모 내용이 표시되고
    // 두 번째 셀에는 날짜가 표시됨
    // 메모 목록에서 구현한 것처럼 tableView에 데이터를 표시할 때는 Observable과 바인딩함
    // tableView에 표시할 데이터는 문자열 2개임
    // 그래서 문자열 배열을 방출함
    // 그냥 Observable로 해도 되는데 BehaviorSubject로 한 이유는?
    // 메모를 편집한 다음에 다시 보기 화면으로 오면 편집한 내용이 반영돼야 함
    // 이렇게 하기 위해서는 새로운 문자열 배열을 방출해야 함
    // 일반 Observable로 선언하면 이게 불가능
    var contents: BehaviorSubject<[String]>
    
    
    init(memo: Memo, title: String, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType) {
        self.memo = memo
        contents = BehaviorSubject<[String]>(value: [
                                                memo.content,
                                                formatter.string(from: memo.insertDate)
        ])
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    
    
    
}
