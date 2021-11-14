//
//  Scene.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit

// 앱에서 구현헐 Scene을 열거형으로 구현
enum Scene {
    // Scene과 연관된 ViewModel을 연관값으로 저장
    case list(MemoListViewModel)
    case detail(MemoDetailViewModel)
    case compose(MemoComposeViewModel)
}

extension Scene {
    // 스토리보드에 있는 Scene을 생성하고 연관값에 저장된 ViewModel을 바인딩해서 리턴하는 메소드
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .list(let viewModel):
            // 여기에서 메모 목록 Scene을 생성한 다음에 ViewModel을 바인딩해서 리턴
            guard let nav = storyboard.instantiateViewController(withIdentifier: "ListNav") as? UINavigationController else {
                fatalError()
            }
            
            guard var listVC = nav.viewControllers.first as? MemoListViewController else {
                fatalError()
            }
            
            // viewModel은 navigationController에 임베드 되어있는 rootViewController에 바인딩하고
            // 리턴할 때는 navigationController를 리턴함
            listVC.bind(viewModel: viewModel)
            return nav
        case .detail(let viewModel):
            // 이 Scene은 항상 내비게이션 스택에 푸시되기 때문에 navigationController를 고려할 필요가 없음
            guard var detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? MemoDetailViewController else {
                fatalError()
            }
            
            detailVC.bind(viewModel: viewModel)
            return detailVC
        case.compose(let viewModel):
            // 메모 보기 Scene은 메모 목록과 마찬가지로 navigationController에 임배드 되어 있음
            // 그래서 메모 목록과 같은 패턴으로 구현
            guard let nav = storyboard.instantiateViewController(withIdentifier: "ComposeNav") as? UINavigationController else {
                fatalError()
            }
            
            guard var composeVC = nav.viewControllers.first as? MemoComposeViewController else {
                fatalError()
            }
            
            // 실제 Scene과 viewModel을 바인딩하고 navigationController를 리턴
            composeVC.bind(viewModel: viewModel)
            return nav
        }
    }
}
