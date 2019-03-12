//
//  Data+Extensions.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public extension Data {
    
    func removeLeft() -> Data {
        var newData = self
        newData.removeFirst()
        return newData
    }
    
    func removeRight() -> Data {
        var newData = self
        newData.removeLast()
        return newData
    }
    
    public var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    public var stringASCII: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
    
    public var stringUTF8: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }
    
// Unused for now
//
//    public var uint16LE: UInt16 {
//        get {
//            let i16array = self.withUnsafeBytes {
//                UnsafeBufferPointer<UInt16>(start: $0, count: self.count/2).map(UInt16.init(littleEndian:))
//            }
//            return i16array[0]
//        }
//    }
//
//    public var uint32LE: UInt32 {
//        get {
//            let i32array = self.withUnsafeBytes {
//                UnsafeBufferPointer<UInt32>(start: $0, count: self.count/2).map(UInt32.init(littleEndian:))
//            }
//            return i32array[0]
//        }
//    }
//
//    public var uint16BE: UInt16 {
//        get {
//            let i16array = self.withUnsafeBytes {
//                UnsafeBufferPointer<UInt16>(start: $0, count: self.count/2).map(UInt16.init(bigEndian:))
//            }
//            return i16array[0]
//        }
//    }
//
//    public var uint32BE: UInt32 {
//        get {
//            let i32array = self.withUnsafeBytes {
//                UnsafeBufferPointer<UInt32>(start: $0, count: self.count/2).map(UInt32.init(bigEndian:))
//            }
//            return i32array[0]
//        }
//    }
//
//    public var uuid: NSUUID? {
//        get {
//            var bytes = [UInt8](repeating: 0, count: self.count)
//            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
//            return NSUUID(uuidBytes: bytes)
//        }
//    }
    
}
