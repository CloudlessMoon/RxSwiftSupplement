//
//  AllocatedUnfairLock.swift
//  RxSwiftSupplement
//
//  Created by jiasong on 2024/5/22.
//

import Foundation

internal final class AllocatedUnfairLock {
    
    private let lock: os_unfair_lock_t
    
    init() {
        self.lock = .allocate(capacity: 1)
        self.lock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        self.lock.deinitialize(count: 1)
        self.lock.deallocate()
    }
    
}

extension AllocatedUnfairLock {
    
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        os_unfair_lock_lock(self.lock); defer { os_unfair_lock_unlock(self.lock) }
        return try body()
    }
    
}
