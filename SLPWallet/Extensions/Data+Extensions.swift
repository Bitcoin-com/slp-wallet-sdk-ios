//
//  Data+Extensions.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

public extension NSData {
    
    public func readUInt32BE(position : Int) -> UInt32 {
        var blocks : UInt32 = 0
        self.getBytes(&blocks, length: position)
        return NSSwapBigIntToHost(blocks)
    }
    
    public func readUInt16BE(position : Int) -> UInt16 {
        var blocks : UInt16 = 0
        self.getBytes(&blocks, length: position)
        return NSSwapBigShortToHost(blocks)
    }
    
    public func readUInt32LE(position : Int) -> UInt32 {
        var blocks : UInt32 = 0
        self.getBytes(&blocks, length: position)
        return NSSwapLittleIntToHost(blocks)
    }
    
    public func readUInt8(position : Int) -> UInt8 {
        var blocks : UInt8 = 0
        self.getBytes(&blocks, length: position)
        return blocks
    }
}

public extension Data {
    
    public var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    public var uint16: UInt16 {
        get {
            let i16array = self.withUnsafeBytes {
                UnsafeBufferPointer<UInt16>(start: $0, count: self.count/2).map(UInt16.init(littleEndian:))
            }
            return i16array[0]
        }
    }
    
    public var uint32: UInt32 {
        get {
            let i32array = self.withUnsafeBytes {
                UnsafeBufferPointer<UInt32>(start: $0, count: self.count/2).map(UInt32.init(littleEndian:))
            }
            return i32array[0]
        }
    }
    
    public var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
            return NSUUID(uuidBytes: bytes)
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
    
}