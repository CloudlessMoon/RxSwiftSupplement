//
//  BehaviorRelayWrapper.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import RxRelay

@propertyWrapper public struct BehaviorRelayWrapper<Value> {
    
    public static subscript<EnclosingSelf: AnyObject>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            return object[keyPath: storageKeyPath].relay.value
        }
        set {
            object[keyPath: storageKeyPath].relay.accept(newValue)
        }
    }
    
    public var projectedValue: BehaviorRelayProjected<Value> {
        return BehaviorRelayProjected(self.relay)
    }
    
    @available(*, unavailable, message: "@BehaviorRelayWrapper is only available on properties of classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    private let relay: BehaviorRelay<Value>
    
    public init(wrappedValue: Value) {
        self.relay = BehaviorRelay(value: wrappedValue)
    }
    
}

extension BehaviorRelayWrapper: CustomStringConvertible {
    
    public var description: String {
        return String(describing: self.relay.value)
    }
    
}

public struct BehaviorRelayProjected<Value> {
    
    private let relay: BehaviorRelay<Value>
    
    fileprivate init(_ relay: BehaviorRelay<Value>) {
        self.relay = relay
    }
    
}

extension BehaviorRelayProjected {
    
    public var observable: Observable<Value> {
        return self.relay.asObservable()
    }
    
    public var infallible: Infallible<Value> {
        return self.relay.asInfallible()
    }
    
}
