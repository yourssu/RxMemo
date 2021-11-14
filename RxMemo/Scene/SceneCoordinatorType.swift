//
//  SceneCoordinatorType.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift

// 여기서는 프로토콜을 선언하고 SceneCoordinator가 공통적으로 구현해야 하는 멤버를 선언

protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable
    // 이 메소드는 새로운 Scene을 표시
    // 파라미터로 대상 Scene과 TransitionStyle, animation flag를 전달함
    
    
    @discardableResult
    func close(animated: Bool) -> Completable
    // 이 메소드는 현재 Scene을 닫고 이전 Scene으로 돌아감
    
    // 위에 두 메소드는 리턴형이 Completable로 되어있음
    // 여기에 구독자를 추가하고 화면 전환이 완료된 후에 원하는 작업을 구현할 수 있음
    // 만약 이런 작업이 필요없다면 그냥 사용하지 않아도 됨
    // @discardableResult 특성을 추가했기 때문에 리턴형을 사용하지 않는다는 경고는 발생하지 않음
}


// 이 프로토콜을 채용한 SceneCoordinator를 구현
