//
//  AnyDisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift

private struct AnyDisposeBagAssociatedKeys {
    static var bag: UInt8 = 0
    static var lock: UInt8 = 0
}

public protocol AnyDisposeBag: AnyObject {
    
    var disposeBag: DisposeBag { get set }
}

public extension AnyDisposeBag {
    
    var disposeBag: DisposeBag {
        get {
            return self.lock.withLock {
                if let disposeBag = objc_getAssociatedObject(self, &AnyDisposeBagAssociatedKeys.bag) as? DisposeBag {
                    return disposeBag
                }
                let disposeBag = DisposeBag()
                objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.bag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeBag
            }
        }
        set {
            self.lock.withLock {
                objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var lock: AllocatedUnfairLock {
        let initialize = {
            let value = AllocatedUnfairLock()
            objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self, &AnyDisposeBagAssociatedKeys.lock) as? AllocatedUnfairLock) ?? initialize()
    }
}
