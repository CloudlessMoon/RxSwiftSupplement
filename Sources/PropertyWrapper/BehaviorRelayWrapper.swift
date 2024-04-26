//
//  BehaviorRelayWrapper.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import RxRelay

@propertyWrapper public final class BehaviorRelayWrapper<Element> {
    
    public private(set) var projectedValue: BehaviorRelayProjected<Element>
    
    public var wrappedValue: Element {
        get {
            guard let queue = self.projectedValue.queue else {
                return self.projectedValue.value
            }
            
            return queue.rx.safeSync {
                return self.projectedValue.value
            }
        }
        set {
            guard let queue = self.projectedValue.queue else {
                self.projectedValue.accept(newValue)
                return
            }
            
            queue.rx.safeSync {
                self.projectedValue.accept(newValue)
            }
        }
    }
    
    public init(wrappedValue: Element) {
        self.projectedValue = BehaviorRelayProjected(wrappedValue: wrappedValue)
    }
    
}

public final class BehaviorRelayProjected<Element> {
    
    private var _queue: DispatchQueue?
    
    private let relay: BehaviorRelay<Element>
    
    private lazy var lock: os_unfair_lock_t = {
        let lock: os_unfair_lock_t = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        return lock
    }()
    
    fileprivate init(wrappedValue: Element) {
        self.relay = BehaviorRelay(value: wrappedValue)
    }
    
    deinit {
        self.lock.deinitialize(count: 1)
        self.lock.deallocate()
    }
    
    private func safeValue<T>(execute work: () -> T) -> T {
        os_unfair_lock_lock(self.lock); defer { os_unfair_lock_unlock(self.lock) }
        return work()
    }
    
    fileprivate var value: Element {
        return self.relay.value
    }
    
    fileprivate func accept(_ value: Element) {
        self.relay.accept(value)
    }
    
}

extension BehaviorRelayProjected {
    
    public var queue: DispatchQueue? {
        get {
            self.safeValue {
                return self._queue
            }
        }
        set {
            self.safeValue {
                self._queue = newValue
            }
        }
    }
    
    /// 注意：与BehaviorRelay一致，不会发送error or completed事件
    public var observable: Observable<Element> {
        return self.relay.asObservable()
    }
    
}
