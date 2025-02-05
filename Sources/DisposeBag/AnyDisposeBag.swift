//
//  AnyDisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import ThreadSafe

public protocol AnyDisposeBag: AnyObject {
    
    var disposeBag: DisposeBag { get set }
}

public extension AnyDisposeBag {
    
    var disposeBag: DisposeBag {
        get {
            return self.readWrite.value
        }
        set {
            self.readWrite.value = newValue
        }
    }
    
    private var readWrite: ReadWriteValue<DisposeBag> {
        let initialize = {
            let value = ReadWriteValue(DisposeBag(), task: ReadWriteTask(label: "com.cloudlessmoon.rxswift-supplement.dispose-bag"))
            objc_setAssociatedObject(self, &AssociatedKeys.readWrite, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self, &AssociatedKeys.readWrite) as? ReadWriteValue<DisposeBag>) ?? initialize()
    }
}

private struct AssociatedKeys {
    static var readWrite: UInt8 = 0
}
