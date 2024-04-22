//
//  DispatchQueue+Extension.swift
//  RxSwiftSupplement
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
    static var detection: UInt8 = 0
    static var reference: UInt8 = 0
    static var lock: UInt8 = 0
}

fileprivate extension DispatchQueue {
    private static let __rx_specificLock: os_unfair_lock_t = {
        let lock: os_unfair_lock_t = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        return lock
    }()
    
    static func safeGetSpecific<T>(key: DispatchSpecificKey<T>) -> T? {
        os_unfair_lock_lock(DispatchQueue.__rx_specificLock)
        defer {
            os_unfair_lock_unlock(DispatchQueue.__rx_specificLock)
        }
        return DispatchQueue.getSpecific(key: key)
    }
}

extension Reactive where Base: DispatchQueue {
    
    @discardableResult
    internal func safeSync<T>(execute work: () -> T) -> T {
        self.registerDetection()
        
        let reference = Base.safeGetSpecific(key: self.detectionKey)
        if let reference = reference, reference.queue == self.base {
            return work()
        } else {
            return self.base.sync(execute: work)
        }
    }
    
    private func registerDetection() {
        let initialize = {
            let value = NSLock()
            value.name = "com.ruanmei.rx-supplement.get-reference"
            objc_setAssociatedObject(self.base, &QueueAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        let lock = (objc_getAssociatedObject(self.base, &QueueAssociatedKeys.lock) as? NSLock) ?? initialize()
        lock.lock(); defer { lock.unlock() }
        
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
        if let detectionKey = objc_getAssociatedObject(self.base, &QueueAssociatedKeys.detection) as? DispatchSpecificKey<QueueReference> {
            return detectionKey
        }
        let detectionKey = DispatchSpecificKey<QueueReference>()
        objc_setAssociatedObject(self.base, &QueueAssociatedKeys.detection, detectionKey, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return detectionKey
    }
    
}
