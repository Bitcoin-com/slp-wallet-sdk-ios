//
//  SLPTransactionParser.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/01.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

// TODO: Move all the parsering here to clean SLPWallet
//

import BitcoinKit

enum SLPTransactionType: String {
    case GENESIS
    case SEND
    case MINT
}

struct SLPTransactionParserResponse {
    var token: SLPToken
    var utxos: [SLPWalletUTXO]
}

class SLPTransactionParser {
    
    static func parse(_ tx: RestService.ResponseTx, vouts: [Int]) -> SLPTransactionParserResponse? {
        
        let parsedToken = SLPToken()
        var parsedUTXOs = [SLPWalletUTXO]()
        
        // TODO: Parse the tx in another place
        let script = Script(hex: tx.vout[0].scriptPubKey.hex)
        
        var voutToTokenQty = [Int]()
        voutToTokenQty.append(0) // To have the same mapping with the vouts
        
        var mintVout = 0
        
        if var chunks = script?.scriptChunks
            , chunks.removeFirst().opCode == .OP_RETURN {
            
            // 0 : lokad id 4 bytes ASCII
            // Good
            guard let lokadId = chunks[0].chunkData.removeLeft().removeRight().stringASCII else {
                return nil
            }
            
            if lokadId == "SLP" {
                
                // 1 : token_type 1 bytes Integer
                // Good
                var chunk = chunks[1].chunkData.removeLeft()
                let tokenType = chunk.uint8 // Unused for now
                
                // 2 : transaction_type 4 bytes ASCII
                // Good
                chunk = chunks[2].chunkData.removeLeft()
                
                guard let transactionType = chunks[2].chunkData.removeLeft().stringASCII else {
                    return nil
                }
                
                switch transactionType {
                case SLPTransactionType.GENESIS.rawValue:
                    
                    // Genesis => Txid
                    let tokenId = tx.txid
                    parsedToken._tokenId = tokenId
                    
                    // 3 : token_ticker UTF8
                    // Good
                    chunk = chunks[3].chunkData.removeLeft()
                    guard let tokenTicker = chunk.stringUTF8 else {
                        return nil
                    }
                    parsedToken._tokenTicker = tokenTicker
                    
                    // 4 : token_name UTF8
                    // Good
                    chunk = chunks[4].chunkData.removeLeft()
                    guard let tokenName = chunk.stringUTF8 else {
                        return nil
                    }
                    parsedToken._tokenName = tokenName
                    
                    // 7 : decimal 1 Byte
                    // Good
                    chunk = chunks[7].chunkData.removeLeft()
                    guard let decimal = Int(chunk.hex, radix: 16) else {
                        return nil
                    }
                    parsedToken._decimal = decimal
                    
                    // 8 : Mint 2 Bytes
                    // Good
                    chunk = chunks[8].chunkData.removeLeft()
                    if let mv = Int(chunk.hex, radix: 16) {
                        mintVout = mv
                    }
                    
                    // 9 to .. : initial_token_mint_quantity 8 Bytes
                    // Good
                    chunk = chunks[9].chunkData.removeLeft()
                    if let balance = Int(chunk.hex, radix: 16) {
                        voutToTokenQty.append(balance)
                    }
                    
                case SLPTransactionType.SEND.rawValue:
                    
                    // 3 : token_id 32 bytes  hex
                    // Good
                    chunk = chunks[3].chunkData.removeLeft()
                    let tokenId = chunk.hex
                    parsedToken._tokenId = tokenId
                    
                    // 4 to .. : token_output_quantity 1..19 8 Bytes / qty
                    for i in 4...chunks.count - 1 {
                        chunk = chunks[i].chunkData.removeLeft()
                        if let balance = Int(chunk.hex, radix: 16) {
                            voutToTokenQty.append(balance)
                        } else {
                            break
                        }
                    }
                case SLPTransactionType.MINT.rawValue:
                    
                    // 3 : token_id 32 bytes  hex
                    // Good
                    chunk = chunks[3].chunkData.removeLeft()
                    let tokenId = chunk.hex
                    parsedToken._tokenId = tokenId
                    
                    // 4 : Mint 2 Bytes
                    // Good
                    chunk = chunks[4].chunkData.removeLeft()
                    if let mv = Int(chunk.hex, radix: 16) {
                        mintVout = mv
                    }
                    
                    // 5 : additional_token_quantity 8 Bytes
                    // Good
                    chunk = chunks[5].chunkData.removeLeft()
                    if let balance = Int(chunk.hex, radix: 16) {
                        voutToTokenQty.append(balance)
                    }
                default: break
                }
            }
        }
        
        // Get the vouts that we are interested in
        vouts.forEach({ i in
            let vout = tx.vout[i]
            
            guard let rawAddress = vout.scriptPubKey.addresses?.first
                , let address = try? AddressFactory.create(rawAddress) else {
                    return
            }
            
            let cashAddress = address.cashaddr
            
            guard vout.n < voutToTokenQty.count
                , voutToTokenQty.count > 1
                , voutToTokenQty[vout.n] > 0 else { // Because we push 1 vout qty by default for the OP_RETURN
                    
                    // We need to avoid using the mint baton
                    if vout.n == mintVout && mintVout > 0 {
                        // UTXO with baton
                        parsedToken._mintUTXO = SLPWalletUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n)
                    } else {
                        // UTXO without token
                        let utxo = SLPWalletUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n)
                        parsedUTXOs.append(utxo)
                    }
                    
                    return
            }
            
            // UTXO with a token
            let rawTokenQty = voutToTokenQty[vout.n]
            let tokenUTXO = SLPTokenUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n, rawTokenQty: rawTokenQty)
            parsedToken.addUTXO(tokenUTXO)
        })
        
        return SLPTransactionParserResponse(token: parsedToken, utxos: parsedUTXOs)
    }
}
