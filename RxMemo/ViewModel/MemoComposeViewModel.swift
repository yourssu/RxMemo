//
//  MemoComposeViewModel.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class MemoComposeViewModel: CommonViewModel {
    // 이 ViewModel은 Compose Scene에서 사용함
    // Compose Scene은 새로운 메모를 추가할 때, 메모를 편집할 때 공통적으로 사용함
    // Compose Scene에 표시할 메모를 저장하는 속성을 선언
    
    // 새로운 메모를 추가할 때는 nil이 저장되고 메모를 편집할 때는 편집할 메모가 저장됨
    private let content: String?
    
    // view에 바인딩할 수 있도록 driver 추가
    var initialText: Driver<String?> {
        return Observable.just(content).asDriver(onErrorJustReturn: nil)
    }
    
    // Compose Scene에서는 저장과 취소 2가지 액션을 구현함
    // 액션을 저장하는 속성 추가
    let saveAction: Action<String, Void>
    let cancelAction: CocoaAction
    // navigationBar에 저장 버튼과 취소 버튼을 추가할 건데 위 두 액션과 바인딩
    
    init(title: String, content: String? = nil, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType, saveAction: Action<String, Void>? = nil, cancelAction: CocoaAction? = nil) {
        self.content = content
        
        // saveAction을 받는 파라미터는 옵셔널로 선언되어 있고 기본값이 nil
        // saveAction 파라미터로 전달된 액션을 그대로 저장하지 않고 Action<String, Void>로 한 번 더 래핑
        // 액션이 전달되었다면 실제로 액션을 실행하고 화면을 닫음
        // 반대로 액션이 전달되지 않았다면 화면만 닫고 끝남
        self.saveAction = Action<String, Void> { input in
            if let action = saveAction {
                action.execute(input)
            }
            
            return sceneCoordinator.close(animated: true).asObservable().map { _ in }
        }
        
        self.cancelAction = CocoaAction {
            if let action = cancelAction {
                action.execute(())
            }
            
            return sceneCoordinator.close(animated: true).asObservable().map { _ in }
        }
        
        // ViewModel에서 취소 코드와 저장 코드를 직접 구현해도 되지만 여기서는 파라미터로 받고 있음
        // ViewModel에서 직접 구현하면 처라 빙삭이 하나로 고정됨
        // 반면, 파라미터로 받으면 이전 화면에서 처리 방식을 동적으로 결정할 수 있다는 장점이 있음
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
}

