//
//  AnyObject+DisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift

private struct DisposeBagAssociatedKeys {
    static var bag: UInt8 = 0
    static var lock: UInt8 = 0
}

public extension Reactive where Base: AnyObject {
    
    var disposeBag: DisposeBag {
        get {
            return self.lock.withLock {
                if let disposeBag = objc_getAssociatedObject(self.base, &DisposeBagAssociatedKeys.bag) as? DisposeBag {
                    return disposeBag
                }
                let disposeBag = DisposeBag()
                objc_setAssociatedObject(self.base, &DisposeBagAssociatedKeys.bag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeBag
            }
        }
        set {
            self.lock.withLock {
                objc_setAssociatedObject(self.base, &DisposeBagAssociatedKeys.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var lock: AllocatedUnfairLock {
        let initialize = {
            let value = AllocatedUnfairLock()
            objc_setAssociatedObject(self.base, &DisposeBagAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self.base, &DisposeBagAssociatedKeys.lock) as? AllocatedUnfairLock) ?? initialize()
    }
    
}
