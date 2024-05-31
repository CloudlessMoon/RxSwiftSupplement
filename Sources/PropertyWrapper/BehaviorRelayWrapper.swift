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
    
    public init(wrappedValue: Element) {
        self.projectedValue = BehaviorRelayProjected(wrappedValue: wrappedValue)
    }
    
}

public final class BehaviorRelayProjected<Element> {
    
    @UnfairLockValueWrapper
    public var task: ReadWriteTask
    
    /// 注意：与BehaviorRelay一致，不会发送error or completed事件
    public var observable: Observable<Element> {
        return self.relay.asObservable()
    }
    
    private let relay: BehaviorRelay<Element>
    
    fileprivate init(wrappedValue: Element, taskLabel: String? = nil) {
        self.relay = BehaviorRelay(value: wrappedValue)
        self.task = ReadWriteTask(label: taskLabel ?? "com.jiasong.rxswift-supplement.behavior-relay")
    }
    
    fileprivate var value: Element {
        get {
            return self.task.read { self.relay.value }
        }
        set {
            self.task.write { self.relay.accept(newValue) }
        }
    }
    
}
