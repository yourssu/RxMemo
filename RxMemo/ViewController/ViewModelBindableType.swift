//
//  ViewModelBindableType.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit


// MVVM 패턴으로 구현할 때는 ViewModel을 ViewController의 속성으로 추가함
// 그런 다음 ViewModel과 View를 바인딩함
// 이런 역할을 수행하는 데에 필요한 프로토콜

// ViewModel의 타입은 ViewController 마다 달라짐
// 그래서 프로토콜을 제너릭 프로토콜로 선언함

protocol ViewModelBindableType {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension ViewModelBindableType where Self: UIViewController {
    // 여기에서는 ViewController에 추가된 ViewModel 속성에 실제 ViewModel을 저장하고
    // bindViewModel() 메소드를 자동으로 호출하는 메소드를 구현
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        
        bindViewModel()
    }
    // 이렇게 하면 개별 ViewController에서 bindViewModel() 메소드를 직접 호출할 필요가 없기 때문에 그만큼 코드가 단순해짐
}


// ViewController에서 위 프로토콜을 채용하기
