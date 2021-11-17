//
//  SceneCoordinator.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation
import RxSwift
import RxCocoa

extension UIViewController {
    // 실제로 화면에 표시되어 있는 ViewController를 리턴하는 속성을 추가
    var sceneViewController: UIViewController {
        // navigationController와 같은 컨테이너 뷰 컨트롤러라면 마지막 child를 리턴하고
        // 나머지 경우에는 self를 그대로 리턴
        // tabbar controller나 다른 컨테이너 컨트롤러를 사용한다면 거기에 맞게 코드를 수정해야됨
        return self.children.first ?? self
    }
}

class SceneCoordinator: SceneCoordinatorType {
    
    // 리소스 정리에 사용됨
    private let bag = DisposeBag()
    
    // SceneCoordinator는 화면 전환을 담당하기 때문에 window 인스턴스와 현재 화면에 표시되어 있는 Scene을 가지고 있어야 함
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable {
        
        // 전환 결과를 방출할 subject
        let subject = PublishSubject<Void>()
        
        
        // Scene을 생성해서 상수에 저장
        // instantiate() 메소드는 Scene 열거형에서 구현함
        let target = scene.instantiate()
        
        
        // TransitionStyle에 따라서 실제 전환을 처리
        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
        case .push:
            // 푸시는 navigationController에 임베드 되어 있을 때에만 의미가 있음
            // 이 부분을 먼저 확인하고 navigationController에 임베드 되어 있지 않다면 Error 이벤트를 전달하고 중지
            guard let nav = currentVC.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            
            
            
            // 애플 공식 문서에서 navigationControllerDelegate 프로토콜을 보면 화면을 전환하기 전에 호출되는 메소드가 있음
            // 이 메소드가 호출되는 시점에 currentVC를 업데이트하는 방식을 사용
            // 직접 delegate 메소드를 구현하는 것도 가능하지만 여기서는 RxCocoa가 제공하는 extension을 활용
            nav.rx.willShow
            // 이 속성은 delegate 메소드가 호출되는 시점마다 Next 이벤트를 방출하는 control event이다
            // 여기에 구독자를 추가하고 currentVC 속성을 업데이트
                .subscribe(onNext: { [unowned self] evt in
                    self.currentVC = evt.viewController.sceneViewController
                })
                .disposed(by: bag)
            
            
            
            
            
            // 반대로 navigationController에 임베드 되어 있다면 Scene을 푸시하고 Completed 이벤트를 전달
            nav.pushViewController(target, animated: animated)
            currentVC = target.sceneViewController
            subject.onCompleted()
        case .modal:
            // Scene을 present
            currentVC.present(target, animated: animated) {
                // Completed 이벤트는 completionHandler에서 전달
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
        }
        
        
        // 이 메소드의 리턴형은 Completable이다
        // subject를 리턴할 때 ignoreElements() 연산자를 호출하면 Completable로 변환되어서 리턴됨
        // 위에서 PublishSubject를 생성하지 않고 처음부터 Completable을 생성해도 되지만 create 연산자로 만들어야 하고 클로저 내부에서 구현해야 하기 때문에 코드가 필요 이상으로 복잡해짐
        // 그래서 PublishSubject와 ignoreElements() 연산자를 활용함
        return subject.ignoreElements().asCompletable()
    }
    
    
    // close 메소드에서는 위에서와 다르게 Completable을 직접 생성하는 방식으로 구현
    @discardableResult
    func close(animated: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            // ViewController가 modal 방식으로 표시되어 있다면 현재 Scene을 dismiss
            if let presentingVC = self.currentVC.presentingViewController {
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC.sceneViewController
                    completable(.completed)
                }
            } else if let nav = self.currentVC.navigationController {
                // navigation 스택에 푸시되어 있다면 팝하기
                // 만약 팝을 할 수 없는 상황이라면 에러 이벤트를 전달하고 종료
                guard nav.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                self.currentVC = nav.viewControllers.last!
                completable(.completed)
            } else {
                // 나머지 경우에는 그냥 에러 이벤트만 전달하고 종료
                completable(.error(TransitionError.unknown))
            }
            
            return Disposables.create()
        }
    }
}
