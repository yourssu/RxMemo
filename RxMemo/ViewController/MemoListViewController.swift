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
            .bind(to: listTableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        // dataSource 메소드 구현 없이 짧은 코드만으로 tableView에 데이터를 표시할 수 있음
        // 셀을 재사용 큐에서 꺼내고 리턴하는 부분도 자동으로 처리됨
        // 클로저에서 셀 구성 코드만 구현하면 됨
        
        
        // +버튼과 액션을 바인딩
        addButton.rx.action = viewModel.makeCreateAction()
        
        
        // detailAction 바인딩
        // tableView에서 메모를 선택하면 ViewModel을 통해서 detailAction을 전달하고 선택한 셀은 선택해제
        // 위 주석의 첫 번째 작업을 하려면 선택한 메모가 필요하고 두 번째 작업에서는 indexPath가 필요함
        // RxCocoa는 선택 이벤트 처리에 사용하는 다양한 멤버를 extension으로 제공함
        // 선택한 indexPath가 필요할 때는 itemSelected 속성을 사용하고 선택한 데이터인 메모가 필요하다면 modelSelected 메소드를 활용함
        // 여기에서는 두 멤버 모두 활용함
        // zip 연산자로 두 멤버가 리턴하는 Observable을 병합
        Observable.zip(listTableView.rx.modelSelected(Memo.self),
                       listTableView.rx.itemSelected)
        // 이렇게 하면 선택된 메모와 indexPath가 튜플 형태로 방출됨
        // 이어서 두 연산자를 추가하고 Next 이벤트가 전달되면 선택 상태를 해제
            .do(onNext: { [unowned self] ( _ , indexPath) in
                self.listTableView.deselectRow(at: indexPath, animated: true)
                // 선택 상태를 처리했기 때문에 이후에는 indexPath가 필요없음
                // 그래서 map 연산자로 데이터만 방출하도록 바꿈
            })
            .map { $0.0 }
        // 마지막으로 전달된 메모를 detailAction과 바인딩
            .bind(to: viewModel.detailAction.inputs)
            .disposed(by: rx.disposeBag)
        // 이렇게 하면 선택한 메모가 액션으로 전달되고 액션에 구현되어 있는 코드가 실행됨
        
        
        
        
        
        // tableView에서 swipe to delete 모드를 활성화하고 삭제 버튼과 액션을 바인딩
        // delegate 메소드를 직접 구현하지 않고 RxCocoa가 제공하는 메소드를 활용
        listTableView.rx.modelDeleted(Memo.self)
        // 이 메소드는 control event를 리턴
        // 그리고 control event는 메모를 삭제할 때마다 Next 이벤트를 방출
        // Control event를 deleteAction과 바인딩
            .bind(to: viewModel.deleteAction.inputs)
            .disposed(by: rx.disposeBag)
        // 이렇게 삭제와 관련된 Control event를 구독하면 swipe to delete가 자동으로 활성화됨
        
        
        
        
        
        // 메모가 삭제될 때 row animation이 실행되도록 수정하려면
        // delegate 메소드를 직접 구현하거나 (기존 코드를 많이 수정해야 됨)
        // RxDataSource를 활용하면 됨 (단순한 코드로 해결 가능)
    }
}
