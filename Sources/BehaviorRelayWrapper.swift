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
    
    public fileprivate(set) var projectedValue: BehaviorRelayProjected<Element>
    
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
            self.lock.lock(); defer { self.lock.unlock() }
            return self._queue
        }
        set {
            self.lock.lock(); defer { self.lock.unlock() }
            self._queue = newValue
        }
    }
    
    public var observable: Observable<Element> {
        return self.behaviorRelay.asObservable()
    }
    
    fileprivate let behaviorRelay: BehaviorRelay<Element>
    private let lock = NSRecursiveLock()
    
    fileprivate init(wrappedValue: Element) {
        self.behaviorRelay = BehaviorRelay(value: wrappedValue)
    }
    
}
