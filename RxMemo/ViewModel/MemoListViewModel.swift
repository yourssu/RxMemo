//
//  MemoListViewModel.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import RxDataSources




// RxDataSources가 요구하는 방식으로 구현
// section model을 생성한 다음에 여기에 section data와 row data를 저장하고
// Observable이 section model 배열을 방출하도록 구현
// 여기서는 RxDataSources가 제공하는 기본 section model 중에서 AnimatableSectionModel을 사용
// 메모 목록은 하나의 섹션에서 표시되고 tableView에서 section header, section footer를 표시하지 않음
// 그래서 section data는 신경 쓸 필요가 없음


// 여기서 사용할 section model의 형식
// sectino data의 형식은 Int
// row data의 형식은 Memo
// 코드를 단순하게 하기 위해서 typealias로 새로운 이름 추가
typealias MemoSectionModel = AnimatableSectionModel<Int, Memo>



class MemoListViewModel: CommonViewModel {
    
    // tableView 바인딩에 사용할 dataSource를 속성으로 선언
    // 클로저를 활용해서 초기화
    let dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<MemoSectionModel>(configureCell: { (dataSource, tableView, indexPath, memo) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = memo.content
            return cell
        })
        
        ds.canEditRowAtIndexPath = { _, _ in return true }
        return ds
    }()
    
    
    // 메모 목록 화면에서 필요한 것은 메모 목록
    // 그래서 tableView와 바인딩할 수 있는 속성을 추가
    // 이 속성은 메모 배열을 방출
    var memoList: Observable<[MemoSectionModel]> {
        // 저장소에 구현되어 있는 memoList() 메소드를 호출하고 메소드가 리턴하는 Observable을 그대로 리턴
        return storage.memoList()
    }
    
    
    
    
    
    // createMemo 메소드로 내용이 없는 메모를 생성하고 실제로 저장하면 입력한 메모로 update 하는 방식
    // -> update인 이유
    func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action { input in
            // Action<String, Void>을 보면 입력 타입이 String으로 선언되어 있음
            // 입력값으로 메모를 업데이트하도록 구현
            return self.storage.update(memo: memo, content: input)
            // Action<String, Void>의 출력 타입이 Void로 선언되어 있음
            // 즉 Observable이 방출하는 형식이 Void라는 뜻
            // 방출하는 형식이 다르기 때문에 에러가 발생해서 map 연산자로 해결
                .map { _ in }
        }
    }
    
    
    
    
    func performCancel(memo: Memo) -> CocoaAction {
        return Action {
            // 생성된 메모를 삭제
            // 아래 함수에서 createMemo 메소드를 호출해서 메모가 실제로 생성되고 Observable로 방출되는데
            // 메모를 삭제하지 않으면 불필요한 메모가 저장되고 tableView에 표시돼서 메모를 삭제함
            return self.storage.delete(memo: memo).map { _ in }
        }
    }
    
    // 목록 화면 상단에 + 버튼이 추가되어 있고 이 버튼을 탭하면 쓰기 화면을 modal 방식으로 표시
    // 이 버튼과 바인딩할 액션 구현
    func makeCreateAction() -> CocoaAction {
        return CocoaAction { _ in
            
            // createMemo 메소드를 호출하면 새로운 메모가 생성되고 이 메모를 방출하는 Observable이 리턴됨
            // 이어서 flatMap 연산자를 호출하고 클로저에서 화면 전환을 처리
            return self.storage.createMemo(content: "")
                .flatMap { memo -> Observable<Void> in
                    // ViewModel 만들기
                    // title은 바로 문자열을 전달하면 되고 sceneCoordinator와 storage에 대한 의존성은 현재 ViewModel에 있는 속성으로 바로 주입할 수 있음
                    let composeViewModel = MemoComposeViewModel(title: "새 메모", sceneCoordinator: self.sceneCoordinator, storage: self.storage, saveAction: self.performUpdate(memo: memo), cancelAction: self.performCancel(memo: memo))
                    
                    
                    // compose scene을 생성하고 연관값으로 ViewModel을 저장
                    let composeScene = Scene.compose(composeViewModel)
                    
                    // scene coordinator에서 transition 메소드를 호출하고 scene을 modal 방식으로 표시
                    return self.sceneCoordinator.transition(to: composeScene, using: .modal, animated: true).asObservable().map { _ in }
                    // transition 메소드는 Completable을 리턴함
                    // map 연산자로 Void 형식을 방출하는 Observable로 바꿔줘야 함
                }
        }
    }
    
    
    
    // 목록 화면에서 보기 화면으로 이동하는 코드
    // 위 코드에서와 다르게 메소드가 아닌 속성 형태로 구현 (메소드로 구현하는 것도 가능한데 다양한 구현 방식을 보여주기 위해서)
    // Action의 입력 형식은 Memo, 출력 형식은 Void로 선언
    // 클로저 내부에서 self에 접근해야 하기 때문에 lazy로 선언
    lazy var detailAction: Action<Memo, Void> = {
        return Action { memo in
            // 여기서 ViewModel을 생성하고 Scene을 생성한 다음에 SceneCoordinator에서 transition 메소드를 호출
            // 목록 화면에서 쓰기 화면으로 이동하는 것과 동일한 패턴
            
            let detailViewModel = MemoDetailViewModel(memo: memo, title: "메모 보기", sceneCoordinator: self.sceneCoordinator, storage: self.storage)
            let detailScene = Scene.detail(detailViewModel)
            
            return self.sceneCoordinator.transition(to: detailScene, using: .push, animated: true).asObservable().map { _ in }   
        }
    }()
    
    
    
    
    
    // detailAction과 동일한 패턴으로 deleteAction 구현
    lazy var deleteAction: Action<Memo, Swift.Never> = {
        return Action { memo in
            return self.storage.delete(memo: memo).ignoreElements()
        }
    }()
}
