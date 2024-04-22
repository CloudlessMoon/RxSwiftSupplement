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
            return self.safeValue {
                if let disposeBag = objc_getAssociatedObject(self, &AnyDisposeBagAssociatedKeys.bag) as? DisposeBag {
                    return disposeBag
                }
                let disposeBag = DisposeBag()
                objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.bag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeBag
            }
        }
        set {
            self.safeValue {
                objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var lock: NSLock {
        let initialize = {
            let value = NSLock()
            value.name = "com.ruanmei.rx-supplement.any-dispose-bag"
            objc_setAssociatedObject(self, &AnyDisposeBagAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self, &AnyDisposeBagAssociatedKeys.lock) as? NSLock) ?? initialize()
    }
    
    private func safeValue<T>(execute work: () -> T) -> T {
        self.lock.lock(); defer { self.lock.unlock() }
        return work()
    }
}
