//
//  Utility.swift
//  HPIView
//
//  Created by Logan Jones on 12/30/16.
//  Copyright © 2016 Logan Jones. All rights reserved.
//

// MARK:- File Read Helpers

extension FileHandle {
    func readData<T>(ofType type: T.Type) -> Data {
        return readData(ofLength: MemoryLayout<T>.size)
    }
    func readData<T>(ofType type: T.Type, count: Int) -> Data {
        return readData(ofLength: MemoryLayout<T>.size * count)
    }
    func readValue<T>(ofType type: T.Type) -> T {
        let data = readData(ofLength: MemoryLayout<T>.size)
        return data.withUnsafeBytes { $0.pointee }
    }
    func readArray<T>(ofType type: T.Type, count: Int) -> [T] {
        let data = readData(ofLength: MemoryLayout<T>.size * count)
        return data.withUnsafeBytes { (p: UnsafePointer<UInt8>) -> [T] in
            let buffer = UnsafeBufferPointer<T>(rebinding: p, capacity: count)
            return Array(buffer)
        }
    }
    @nonobjc func readData(ofLength length: UInt32) -> Data {
        return readData(ofLength: Int(length))
    }
    @nonobjc func seek(toFileOffset offset: UInt32) {
        seek(toFileOffset: UInt64(offset))
    }
    @nonobjc func seek(toFileOffset offset: Int) {
        seek(toFileOffset: UInt64(offset))
    }
}

// MARK:- Data Extensions

extension Data {
    func withUnsafeRawBytes<ResultType>(_ body: (UnsafeRawPointer) throws -> ResultType) rethrows -> ResultType {
        return try self.withUnsafeBytes { return try body(UnsafeRawPointer($0)) }
    }
}

// MARK:- Memory Extensions

extension UnsafePointer {
    init<T>(rebinding p: UnsafePointer<T>) {
        let raw = UnsafeRawPointer(p)
        self.init(raw.assumingMemoryBound(to: Pointee.self))
    }
}

extension UnsafeBufferPointer {
    init<T>(rebinding p: UnsafePointer<T>, capacity count: Int) {
        let raw = UnsafeRawPointer(p)
        let rebound = raw.assumingMemoryBound(to: Element.self)
        self.init(start: rebound, count: count)
    }
}

extension UnsafeRawPointer {
    public func bindMemoryBuffer<T>(to type: T.Type, capacity count: Int) -> UnsafeBufferPointer<T> {
        let p = self.bindMemory(to: type, capacity: count)
        return UnsafeBufferPointer<T>(start: p, count: count)
    }
    public func bindMemoryBuffer<T>(to type: T.Type, capacity count: UInt32) -> UnsafeBufferPointer<T> {
        return bindMemoryBuffer(to: type, capacity: Int(count))
    }
}

public func +<Pointee>(lhs: UnsafePointer<Pointee>, rhs: UInt32) -> UnsafePointer<Pointee> {
    return lhs + Int(rhs)
}
public func +(lhs: UnsafeRawPointer, rhs: UInt32) -> UnsafeRawPointer {
    return lhs + Int(rhs)
}

// MARK:- Array Helpers

extension Array {
    public subscript(index: UInt16) -> Element { return self[Int(index)] }
}

extension Array {
    
    init(count: Int, eachValue valueInit: (Int) -> Element ) {
        var a = Array<Element>()
        a.reserveCapacity(count)
        for i in 0..<count {
            a.append(valueInit(i))
        }
        self = a
    }
    
    mutating func replaceElements<S>(withContentsOf s: S, startingAt index: Index = 0) where Element == S.Element, S : Sequence {
        var i = index
        for e in s {
            guard i < count else { break }
            self[i] = e
            i += 1
        }
    }
    
    public subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
    
}

// MARK:- String Formatters

extension UInt8 {
    var hexString: String {
        return "0x"+String(self, radix: 16, uppercase: true).padLeft(with: "0", toLength: 2)
    }
}
extension UInt16 {
    var hexString: String {
        return "0x"+String(self, radix: 16, uppercase: true).padLeft(with: "0", toLength: 4)
    }
}
extension UInt32 {
    var hexString: String {
        return "0x"+String(self, radix: 16, uppercase: true).padLeft(with: "0", toLength: 8)
    }
}

extension UInt8 {
    var binaryString: String {
        return "b("
        + String(self, radix: 2, uppercase: true)
            .padLeft(with: "0", toLength: 8)
            .splitEvery(4, with: " ")
        + ")"
    }
}
extension UInt16 {
    var binaryString: String {
        return "b("
            + String(self, radix: 2, uppercase: true)
                .padLeft(with: "0", toLength: 16)
                .splitEvery(4, with: " ")
            + ")"
    }
}
extension UInt32 {
    var binaryString: String {
        return "b("
            + String(self, radix: 2, uppercase: true)
                .padLeft(with: "0", toLength: 32)
                .splitEvery(4, with: " ")
            + ")"
    }
}

extension String {
    
    func padLeft(with character: String, toLength length: Int) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }
        return String(repeating: character, count: padCount) + self
    }
    
    func splitEvery(_ stride: Int, with splitter: String) -> String {
        var out = ""
        var counter = 0
        for c in self {
            if counter == stride {
                out.append(splitter)
                counter = 1
            }
            else {
                counter += 1
            }
            out.append(c)
        }
        return out
    }
    
}

// MARK:- Errors

struct RuntimeError: Error, CustomStringConvertible {

    var description: String
    
    init(_ description: String) {
        self.description = description
    }
    
}

// MARK:- Next Power of Two

extension UInt32 {
    var nextPowerOfTwo: UInt32 {
        var uiNum = self
        uiNum -= 1
        uiNum |= uiNum >> 16
        uiNum |= uiNum >> 8
        uiNum |= uiNum >> 4
        uiNum |= uiNum >> 2
        uiNum |= uiNum >> 1
        return uiNum + 1
    }
}

extension UInt64 {
    var nextPowerOfTwo: UInt64 {
        var uiNum = self
        uiNum -= 1
        uiNum |= uiNum >> 32
        uiNum |= uiNum >> 16
        uiNum |= uiNum >> 8
        uiNum |= uiNum >> 4
        uiNum |= uiNum >> 2
        uiNum |= uiNum >> 1
        return uiNum + 1
    }
}

// MARK:- Integer Partitioning

extension Int {
    
    func partitions(by divisor: Int) -> [Int] {
        guard divisor < self else { return [self] }
        
        let count = self.partitionCount(by: divisor)
        var array = [Int](repeating: divisor, count: count)
        
        let leftOver = (divisor * count) - self
        if (leftOver > 0) { array[count-1] = leftOver }
        
        return array
    }
    
    func partitionCount(by divisor: Int) -> Int {
        return (self + divisor - 1) / divisor
    }
    
}
