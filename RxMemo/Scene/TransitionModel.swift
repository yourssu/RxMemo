//
//  TransitionModel.swift
//  RxMemo
//
//  Created by Yonghyun on 2021/11/14.
//

import Foundation

// 전환 방식을 표현하는 열거형
enum TransitionStyle {
    case root
    case push
    case modal
}


// 화면 전환에서 문제가 발생했을 때 사용할 에러 형식
enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
