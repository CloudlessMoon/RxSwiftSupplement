//
//  BehaviorRelayed.swift
//  RxPropertyWrapper
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import RxSwift
import RxRelay

@propertyWrapper public final class BehaviorRelayed<Element> {
    
    public var wrappedValue: Element {
        get {
            return self.behaviorRelay.value
        }
        set {
            self.behaviorRelay.accept(newValue)
        }
    }
    
    fileprivate let behaviorRelay: BehaviorRelay<Element>
    
    public init(wrappedValue: Element) {
        self.behaviorRelay = BehaviorRelay(value: wrappedValue)
    }
    
    public var projectedValue: Observable<Element> {
        return self.behaviorRelay.asObservable()
    }
    
}
