//
//  AnyDisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift

private struct AnyDisposeBagAssociatedKeys {
    static var lock: UInt8 = 0
}

public protocol AnyDisposeBag: AnyObject {
    
    var disposeBag: DisposeBag { get set }
}

public extension AnyDisposeBag {
    
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
            objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self, &AnyDisposeBagAssociatedKeys.lock) as? AllocatedUnfairLock<DisposeBag>) ?? initialize()
    }
}
