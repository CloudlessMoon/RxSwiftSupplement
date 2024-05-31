//
//  DispatchQueue+Extension.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2023/7/18.
//

import RxSwift

fileprivate extension DispatchQueue {
    
    static let mainKey: DispatchSpecificKey<UUID> = {
        let key = DispatchSpecificKey<UUID>()
        DispatchQueue.main.setSpecific(key: key, value: UUID())
        return key
    }()
    
}

extension Reactive where Base: DispatchQueue {
    
    internal static var isMain: Bool {
        return Base.getSpecific(key: Base.mainKey) != nil
    }
    
}
