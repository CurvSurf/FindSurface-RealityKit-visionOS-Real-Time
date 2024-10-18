//
//  Queue.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 9/6/24.
//

import Foundation

public struct Queue<T>: RandomAccessCollection, Sequence {
    
    private var entries: [T]
    fileprivate private(set) var currentIndex: Int = 0
    public private(set) var capacity: Int
    
    public init(capacity: Int) {
        var entries = [T]()
        entries.reserveCapacity(capacity)
        self.entries = entries
        self.capacity = capacity
    }
    
    public var startIndex: Int { entries.startIndex }
    public var endIndex: Int { entries.endIndex }
    
    // Collection 프로토콜을 준수하기 위해 필요한 서브스크립트 구현
    public subscript(index: Int) -> T {
        if entries.count < capacity {
            return entries[index]
        } else {
            let index = (currentIndex + index) % capacity
            return entries[index]
        }
    }
    
    // Collection 프로토콜을 준수하기 위한 index(after:) 구현
    public func index(after i: Int) -> Int {
        return entries.index(after: i)
    }
    
    // 현재 큐의 요소 개수를 반환하는 계산된 속성
    public var count: Int {
        return entries.count
    }
    
    public mutating func resize(capacity: Int) {
        guard self.capacity != capacity else { return }

        defer {
            self.capacity = capacity
        }
        
        guard currentIndex != 0 else {
            if self.capacity > capacity { // shrinking
                entries = Array(entries[..<capacity])
            } else { // expanding
                entries.reserveCapacity(capacity)
            }
            return
        }
        
        if self.capacity < capacity { // expanding
            let firstRun = Array(entries[currentIndex...])
            let secondRun = Array(entries[..<currentIndex])
            entries = firstRun + secondRun
        } else if currentIndex + capacity <= entries.count { // shrinking 1
            entries = Array(entries[currentIndex..<(currentIndex + capacity)])
        } else { // shrinking 2
            let firstRun = Array(entries[currentIndex...])
            let secondRun = Array(entries[..<(capacity - firstRun.count)])
            entries = firstRun + secondRun
        }
        currentIndex = 0
    }
    
    public mutating func enqueue(_ element: T) {
        guard entries.count == capacity else {
            entries.append(element)
            return
        }
            
        entries[currentIndex] = element
        currentIndex = (currentIndex + 1) % capacity
    }
}
