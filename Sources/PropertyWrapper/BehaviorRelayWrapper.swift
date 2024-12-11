//
//  BehaviorRelayWrapper.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import RxRelay
import ThreadSafe

@propertyWrapper public final class BehaviorRelayWrapper<Element> {
    
    public let projectedValue: BehaviorRelayProjected<Element>
    
    public var wrappedValue: Element {
        get {
            return self.projectedValue.value
        }
        set {
            self.projectedValue.value = newValue
        }
    }
    
    public init(wrappedValue: Element, task: ReadWriteTask? = .init(label: "com.jiasong.rxswift-supplement.behavior-relay")) {
        self.projectedValue = BehaviorRelayProjected(wrappedValue: wrappedValue, task: task)
    }
    
}

public final class BehaviorRelayProjected<Element> {
    
    @UnfairLockValueWrapper
    public var task: ReadWriteTask?
    
    /// 注意：与BehaviorRelay一致，不会发送error or completed事件
    public var observable: Observable<Element> {
        return self.relay.asObservable()
    }
    
    private let relay: BehaviorRelay<Element>
    
    fileprivate init(wrappedValue: Element, task: ReadWriteTask?) {
        self.relay = BehaviorRelay(value: wrappedValue)
        self.task = task
    }
    
    fileprivate var value: Element {
        get {
            guard let task = self.task else {
                return self.relay.value
            }
            return task.read {
                return self.relay.value
            }
        }
        set {
            guard let task = self.task else {
                self.relay.accept(newValue)
                return
            }
            task.write {
                self.relay.accept(newValue)
            }
        }
    }
    
}
