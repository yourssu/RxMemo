//
//  MemoDetailViewController.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import UIKit

class MemoDetailViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoDetailViewModel!
    
    @IBOutlet var listTableView: UITableView!
    
    
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    func bindViewModel() {
        
    }

}
