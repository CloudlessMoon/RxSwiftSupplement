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

extension BehaviorRelayWrapper: CustomStringConvertible {
    
    public var description: String {
        return String(describing: self.wrappedValue)
    }
    
}

public final class BehaviorRelayProjected<Element> {
    
    /// 注意：与BehaviorRelay一致，不会发送error or completed事件
    public var observable: Observable<Element> {
        return self.relay.asObservable()
    }
    
    fileprivate var value: Element {
        get {
            return self.relay.value
        }
        set {
            self.relay.accept(newValue)
        }
    }
    
    private let relay: BehaviorRelay<Element>
    
    fileprivate init(wrappedValue: Element) {
        self.relay = BehaviorRelay(value: wrappedValue)
    }
    
}
