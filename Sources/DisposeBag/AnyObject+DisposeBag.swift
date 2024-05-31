//
//  AnyObject+DisposeBag.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import ThreadSafe

private struct AssociatedKeys {
    static var readWrite: UInt8 = 0
}

public extension Reactive where Base: AnyObject {
    
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
            let value = ReadWriteValue(DisposeBag(), task: ReadWriteTask(label: "com.jiasong.rxswift-supplement.dispose-bag"))
            objc_setAssociatedObject(self.base, &AssociatedKeys.readWrite, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self.base, &AssociatedKeys.readWrite) as? ReadWriteValue<DisposeBag>) ?? initialize()
    }
    
}
