//
//  AnyObject+DisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import ThreadSafe

public extension Reactive where Base: AnyObject {
    
    var disposeBag: DisposeBag {
        get {
            return self._disposeBag.value
        }
        set {
            self._disposeBag.value = newValue
        }
    }
    
    private var _disposeBag: UnfairLockValue<DisposeBag> {
        if let disposeBag = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? UnfairLockValue<DisposeBag> {
            return disposeBag
        } else {
            let disposeBag = UnfairLockValue(DisposeBag())
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return disposeBag
        }
    }
    
}

private enum AssociatedKeys {
    static var disposeBag: UInt8 = 0
}
