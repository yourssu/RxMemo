//
//  MemoComposeViewController.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

class MemoComposeViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoComposeViewModel!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    func bindViewModel() {
        // navigationTitle 바인딩
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        
        // initialText를 TextView에 바인딩
        viewModel.initialText
            .drive(contentTextView.rx.text)
            .disposed(by: rx.disposeBag)
        // 메모 쓰기 모드에서는 빈 문자열이 표시되고 편집 모드에서는 편집할 메모가 표시됨
        
        
        // 취소 버튼은 cancelAction과 바인딩
        cancelButton.rx.action = viewModel.cancelAction
        // 액션 패턴으로 액션을 구현할 때는 위 코드처럼 액션 속성에 저장하는 방식으로 바인딩
        // 취소 버튼을 탭하면 cancelAction에 래핑되어있는 코드가 실행됨
        
        // 세이브 버튼을 바인딩
        // 버튼을 탭하면 textView에 입력된 문자열을 저장해야됨
        // 그래서 cancelButton과 조금 다른 방식으로 구현해야함
        // tap 속성에 바인딩할건데 더블탭을 막기 위해서 throttle 연산자로 0.5초마다 한 번씩만 탭을 처리
        // withLatestFrom 연산자로 TextView에 입력된 text를 방출
        // 방출된 text를 saveAction과 바인딩
        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(contentTextView.rx.text.orEmpty)
            .bind(to: viewModel.saveAction.inputs)
            .disposed(by: rx.disposeBag)
        
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 키보드 입력이 바로 활성화되도록 하는 코드
        contentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 이전 Scene으로 돌아가기 전에 FirstResponder 해제
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }
}
