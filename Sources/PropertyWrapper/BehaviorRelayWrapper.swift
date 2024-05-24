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
                return self.projectedValue.relay.value
            }
            
            return queue.rx.safeSync {
                return self.projectedValue.relay.value
            }
        }
        set {
            guard let queue = self.projectedValue.queue else {
                self.projectedValue.relay.accept(newValue)
                return
            }
            
            queue.rx.safeSync {
                self.projectedValue.relay.accept(newValue)
            }
        }
    }
    
    public init(wrappedValue: Element) {
        self.projectedValue = BehaviorRelayProjected(wrappedValue: wrappedValue)
    }
    
}

public final class BehaviorRelayProjected<Element> {
    
    fileprivate let relay: BehaviorRelay<Element>
    
    private let lock: AllocatedUnfairLock<DispatchQueue?>
    
    fileprivate init(wrappedValue: Element) {
        self.relay = BehaviorRelay(value: wrappedValue)
        self.lock = AllocatedUnfairLock(state: nil)
    }
    
}

extension BehaviorRelayProjected {
    
    public var queue: DispatchQueue? {
        get {
            self.lock.withLock { $0 }
        }
        set {
            self.lock.withLock { $0 = newValue }
        }
    }
    
    /// 注意：与BehaviorRelay一致，不会发送error or completed事件
    public var observable: Observable<Element> {
        return self.relay.asObservable()
    }
    
}
