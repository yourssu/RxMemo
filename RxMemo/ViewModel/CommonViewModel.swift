//
//  CommonViewModel.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/16.
//

import Foundation
import RxSwift
import RxCocoa

class CommonViewModel: NSObject {
    // 앱을 구성하고 있는 모든 Scene은 navigationController에 임베디드 되기 때문에
    // navigationTitle이 필요함
    
    // title 속성을 추가하고 driver 형식으로 선언
    // 이렇게 하면 navigationItem에 쉽게 바인딩할 수 있음
    let title: Driver<String>
    
    // Scene Coordinator와 저장소를 저장하는 속성 선언
    // 아래 두 속성의 형식을 보면 실제 형식이 아니라 프로토콜로 선언함
    // 이렇게 하면 의존성을 쉽게 수정할 수 있음
    let sceneCoordinator: SceneCoordinatorType
    let storage: MemoStorageType
    
    // 속성을 초기화하는 생성자
    init(title: String, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType) {
        self.title = Observable.just(title).asDriver(onErrorJustReturn: "")
        self.sceneCoordinator = sceneCoordinator
        self.storage = storage
    }
}
