//
//  BehaviorRelayMainThreadWrapper.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2024/12/11.
//

import Foundation
import RxSwift
import RxRelay
import ThreadSafe

@propertyWrapper public final class BehaviorRelayMainThreadWrapper<Element> {
    
    public let projectedValue: BehaviorRelayMainThreadProjected<Element>
    
    public var wrappedValue: Element {
        get {
            return self.projectedValue.value
        }
        set {
            self.projectedValue.value = newValue
        }
    }
    
    public init(wrappedValue: Element) {
        self.projectedValue = BehaviorRelayMainThreadProjected(wrappedValue: wrappedValue)
    }
    
}

public final class BehaviorRelayMainThreadProjected<Element> {
    
    /// 注意：与BehaviorRelay一致，不会发送error or completed事件
    public var observable: Observable<Element> {
        return self.relay.asObservable()
    }
    
    private let task = MainThreadTask.default
    private let relay: BehaviorRelay<Element>
    
    fileprivate init(wrappedValue: Element) {
        self.relay = BehaviorRelay(value: wrappedValue)
    }
    
    fileprivate var value: Element {
        get {
            return self.task.sync {
                return self.relay.value
            }
        }
        set {
            self.task.sync {
                self.relay.accept(newValue)
            }
        }
    }
    
}
