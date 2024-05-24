//
//  AnyObject+DisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift

private struct DisposeBagAssociatedKeys {
    static var lock: UInt8 = 0
}

public extension Reactive where Base: AnyObject {
    
    var disposeBag: DisposeBag {
        get {
            self.lock.withLock { $0 }
        }
        set {
            self.lock.withLock { $0 = newValue }
        }
    }
    
    private var lock: AllocatedUnfairLock<DisposeBag> {
        let initialize = {
            let value = AllocatedUnfairLock(state: DisposeBag())
            objc_setAssociatedObject(self.base, &DisposeBagAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self.base, &DisposeBagAssociatedKeys.lock) as? AllocatedUnfairLock<DisposeBag>) ?? initialize()
    }
    
}
