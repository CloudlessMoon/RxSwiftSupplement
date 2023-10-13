//
//  DispatchQueue+Extension.swift
//  RxPropertyWrapper
//
//  Created by jiasong on 2023/7/18.
//

import RxSwift

private final class QueueReference {
    weak var queue: DispatchQueue?
    
    init(queue: DispatchQueue?) {
        self.queue = queue
    }
    
    deinit {
        print("QueueReference deinit")
    }
}

private struct QueueAssociatedKeys {
    static var specific: UInt8 = 0
    static var reference: UInt8 = 0
}

extension Reactive where Base: DispatchQueue {
    
    internal func safeSync<T>(execute work: () -> T) -> T {
        if let value = Base.getSpecific(key: self.detectionKey), value.queue == self.base {
            return work()
        } else {
            self.registerSpecific()
            return self.base.sync(execute: work)
        }
    }
    
    internal func registerSpecific() {
        let valueLeft = self.base.getSpecific(key: self.detectionKey)
        let valueRight = objc_getAssociatedObject(self.base, &QueueAssociatedKeys.reference) as? QueueReference
        guard valueLeft?.queue == nil || valueRight?.queue == nil || valueLeft?.queue != valueRight?.queue else {
            return
        }
        let value = QueueReference(queue: self.base)
        objc_setAssociatedObject(self.base, &QueueAssociatedKeys.reference, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.base.setSpecific(key: self.detectionKey, value: value)
    }
    
    private var detectionKey: DispatchSpecificKey<QueueReference> {
        if let specific = objc_getAssociatedObject(self.base, &QueueAssociatedKeys.specific) as? DispatchSpecificKey<QueueReference> {
            return specific
        }
        let specific = DispatchSpecificKey<QueueReference>()
        objc_setAssociatedObject(self.base, &QueueAssociatedKeys.specific, specific, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return specific
    }
    
}
