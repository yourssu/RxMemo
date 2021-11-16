//
//  MemoListViewController.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class MemoListViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoListViewModel!
    
    @IBOutlet var listTableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    func bindViewModel() {
        // ViewModel과 View를 바인딩
        
        // ViewModel에 저장되어 있는 title을 navigationTitle과 바인딩
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        // 이렇게 하면 ViewModel에 저장된 title이 navigationBar에 표시됨
        
        
        // 메모 목록을 tableView에 바인딩
        // Observable과 tableView를 바인딩하는 방식으로 구현
        viewModel.memoList
            .bind(to: listTableView.rx.items(cellIdentifier: "cell")) { row, memo, cell in
                cell.textLabel?.text = memo.content
            }
            .disposed(by: rx.disposeBag)
        // dataSource 메소드 구현 없이 짧은 코드만으로 tableView에 데이터를 표시할 수 있음
        // 셀을 재사용 큐에서 꺼내고 리턴하는 부분도 자동으로 처리됨
        // 클로저에서 셀 구성 코드만 구현하면 됨
        
        
        // +버튼과 액션을 바인딩
        addButton.rx.action = viewModel.makeCreateAction()
    }
}
