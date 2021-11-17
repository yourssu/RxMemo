//
//  MemoDetailViewController.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa

class MemoDetailViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoDetailViewModel!
    
    @IBOutlet var listTableView: UITableView!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!     // 메모를 공유할 수 있는 버튼
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    func bindViewModel() {
        // navigationTitle 바인딩
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        // tableView와 content 속성 바인딩
        viewModel.contents
            .bind(to: listTableView.rx.items) { tableView, row, value in
                switch row {
                case 0: // 첫 번째 셀이라면 contentCell을 꺼내서 label에 문자열을 표시하고 리턴
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell")!
                    cell.textLabel?.text = value
                    return cell
                case 1: // 두 번째 셀이라면 dateCell을 꺼내서 같은 방식으로 구현
                    let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell")!
                    cell.textLabel?.text = value
                    return cell
                default:
                    fatalError()
                }
            }
            .disposed(by: rx.disposeBag)
        // 메모를 편집한 후에 tableView를 업데이트 해야 되는데 단순히 reloadData 메소드를 호출하는 방식으로는 편집된 메모가 안 보이는 문제 해결을 못 함
        // Subject와 바인딩 되어 있는데 Subject가 편집한 내용을 다시 방출하도록 수정해야함
        
        
        
        // 편집 버튼 바인딩
        editButton.rx.action = viewModel.makeEditAction()
        
        
        
        // 공유 버튼
        shareButton.rx.tap
            // 더블탭 막기
            // 탭 이벤트는 0.5초 마다 하나씩 전달됨
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            // 구독자 추가
            .subscribe(onNext: {[weak self] _ in
                guard let memo = self?.viewModel.memo.content else { return }
                
                let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        
        // 편집 버튼은 action을 활용
        // 공유 버튼은 tap 속성을 활용함
        // 즉, 2가지 방식을 모두 구현해봄
        // 공유 버튼을 action을 활용하는 방식으로 수정해보기
        // 그러면 2가지 방식이 어떤 장단점을 가지고 있고 어떤 상황에서 활용하면 좋은지 판단할 수 있게 됨
    }

}
