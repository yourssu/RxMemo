//
//  AppDelegate.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Scene Coordinator를 사용해서 첫 번째 화면 표시
        
        // Scene 열거형이 선언되어 있는 listScene 생성
        // viewModel 값을 전달해야 돼서 viewModel도 생성
        // viewModel을 생성하기 위해서는 title, Scene Coordinator, 메모 저장소가 필요함
        // 그래서 필요한 인스턴스를 생성하고 파라미터로 전달
//        let storage = MemoryStorage()
        let coordinator = SceneCoordinator(window: window!)
        
        
        
        
        let storage = CoreDataStorage(modelName: "RxMemo")
        
        // ViewModel을 생성하는 시점에 storage에 의존성이 주입되고 있음
        // 그리고 MemoListViewModel.swift의 makeCreateAction()에서 composeViewModel을 생성하면서 동일한 의존성을 주입하고 있음
        // MemoListViewModel.swift의 detailAction에서도 마찬가지임
        // 그래서 가장 먼저 생성되는 MemoListViewModel의 의존성을 수정하면 나머지 ViewModel에 자동으로 적용됨
        let listViewModel = MemoListViewModel(title: "나의 메모", sceneCoordinator: coordinator, storage: storage)
        let listScene = Scene.list(listViewModel)
        
        
        
        
        // coordinator에서 transition 메소드를 호출하고 listScene을 rootScnee으로 설정
        coordinator.transition(to: listScene, using: .root, animated: false)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
}
