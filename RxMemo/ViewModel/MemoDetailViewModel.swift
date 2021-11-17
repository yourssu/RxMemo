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
    
    
    
    // 뒤로 가기 버튼에 로직 추가하는 이유
    // navigationController가 기본적으로 제공하는 뒤로 가기 버튼은 Scene Coordinator와 아무런 관련이 없음
    // 그래서 뒤로 가기 버튼을 누르면 currentVC 속성은 업데이트 되지 않음
    // 그래서 이전 ViewController가 그대로 저장되어 있음
    // 이 문제를 해결하려면 뒤로 가기 버튼을 누르면 SceneCoordinator의 close 메소드가 호출되도록 하게 하면 됨
    // backButton과 바인딩할 액션 추가
    lazy var popAction = CocoaAction { [unowned self] in
        // 액션 내부에서는 SceneCoordinator에 있는 close 메소드를 호출
        return self.sceneCoordinator.close(animated: true).asObservable().map { _ in }
    }
    
    
    
    // 메모를 편집하고 저장 버튼을 탭하면 이 액션이 실행됨
    func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action { input in
            // 여기서 리턴하는 액션은 ComposeViewModel로 전달하는 액션
            self.storage.update(memo: memo, content: input)
            // 구독자를 추가하고 subject로 업데이트된 메모를 전달
                .subscribe(onNext: { updated in
                    // 여기서 새로운 내용을 subject로 전달하니까 subject는 이 내용을 Next 이벤트에 담아서 방출
                    // 그러면 subject와 바인딩 되어 있는 tableView가 새로운 내용으로 업데이트됨
                    self.contents.onNext([
                                            updated.content,
                                            self.formatter.string(from: updated.insertDate)
                    ])
                })
                .disposed(by: self.rx.disposeBag)
            
            return Observable.empty()
        }
    }
    
    
    
    // 보기 화면에 있는 편집 버튼과 바인딩할 액션 구현
    func makeEditAction() -> CocoaAction {
        return CocoaAction { _ in
            // ComposeViewModel 생성
            // 이 모델은 편집 모드에서 사용됨
            // 그래서 title 파라미터에 "메모 편집"을 전달하고
            // content 파라미터에 편집할 내용을 전달
            // 나머지 파라미터는 이전과 동일
            // cancelAction은 따로 전달할 필요가 없음
            let composeViewModel = MemoComposeViewModel(title: "메모 편집", content: self.memo.content, sceneCoordinator: self.sceneCoordinator, storage: self.storage, saveAction: self.performUpdate(memo: self.memo))
            
            // compose scene 생성
            let composeScene = Scene.compose(composeViewModel)
            
            return self.sceneCoordinator.transition(to: composeScene, using: .modal, animated: true).asObservable().map { _ in }
        }
    }
}
