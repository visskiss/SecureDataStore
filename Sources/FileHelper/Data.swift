//
//  Data.swift
//  FileHelper
//
//  Created by Daniel Kanaan on 9/30/16.
//  Copyright © 2016 Daniel Kanaan. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
   /* func hexString() -> String {
        var string = String()
        for i in 0..<count {
            string += Int(self[i]).hexString()
        }
        return string
    }*/
    
  /*  func MD5() -> Data {
        //let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        //var result = Data(capacity: Int(CC_MD5_DIGEST_LENGTH))
        let digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5((self as NSData).bytes, CC_LONG(count), UnsafeMutablePointer<UInt8>(mutating:digest))
        return Data(bytes:digest)
    }*/
    func HSHA(key:Data) -> Data {
        //let digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        /* let keyBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: key.count)
         key.copyBytes(to: keyBytes, count: key.count)
         let dataBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: self.count)
         copyBytes(to: dataBytes, count: self.count)*/
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity:  Int(CC_SHA512_DIGEST_LENGTH))
        result.initialize(to: 0)
        defer {
            result.deinitialize(count: Int(CC_SHA512_DIGEST_LENGTH))
            result.deallocate()
        }
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), (key as NSData).bytes, key.count, (self as NSData).bytes, self.count,result)
        return Data(bytes: result, count: Int(CC_SHA512_DIGEST_LENGTH))
    }
    
    /* func SHA1() -> Data {
     let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
     CC_SHA1((self as NSData).bytes, CC_LONG(count), UnsafeMutablePointer<UInt8>(result.mutableBytes))
     return (NSData(data: result as Data) as Data)
     }*/
}
