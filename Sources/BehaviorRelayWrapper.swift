//
//  BehaviorRelayWrapper.swift
//  RxPropertyWrapper
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
                return self.projectedValue.behaviorRelay.value
            }
            
            return queue.rx.safeSync {
                return self.projectedValue.behaviorRelay.value
            }
        }
        set {
            guard let queue = self.projectedValue.queue else {
                self.projectedValue.behaviorRelay.accept(newValue)
                return
            }
            
            queue.rx.safeSync {
                self.projectedValue.behaviorRelay.accept(newValue)
            }
        }
    }
    
    public init(wrappedValue: Element) {
        self.projectedValue = BehaviorRelayProjected(wrappedValue: wrappedValue)
    }
    
}

public final class BehaviorRelayProjected<Element> {
    
    private var _queue: DispatchQueue?
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
    
    public var observable: Observable<Element> {
        return self.behaviorRelay.asObservable()
    }
    
    fileprivate let behaviorRelay: BehaviorRelay<Element>
    
    private lazy var lock: os_unfair_lock_t = {
        let lock: os_unfair_lock_t = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        return lock
    }()
    
    fileprivate init(wrappedValue: Element) {
        self.behaviorRelay = BehaviorRelay(value: wrappedValue)
    }
    
    deinit {
        self.lock.deinitialize(count: 1)
        self.lock.deallocate()
    }
    
    private func safeValue<T>(execute work: () -> T) -> T {
        os_unfair_lock_lock(self.lock); defer { os_unfair_lock_unlock(self.lock) }
        return work()
    }
    
}
