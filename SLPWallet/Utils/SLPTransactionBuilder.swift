//
//  SLPTransactionBuilder.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/04.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import BitcoinKit

public enum SLPTransactionBuilderError: String, Error {
    case CONVERSION_METADATA
    case CONVERSION_AMOUNT
    case CONVERSION_CHANGE
    case DECIMAL_NOT_AVAILABLE
    case GAS_INSUFFICIENT
    case INSUFFICIENT_FUNDS
    case SCRIPT_TO
    case SCRIPT_TOKEN_CHANGE
    case SCRIPT_CHANGE
    case TO_ADDRESS_INVALID
    case TOKEN_NOT_FOUND
    case WALLET_ADDRESS_INVALID
}

struct SLPTransactionBuilderResponse {
    var rawTx: String
    var usedUTXOs: [SLPWalletUTXO]
    var newUTXOs: [SLPWalletUTXO]
}

class SLPTransactionBuilder {
    
    static func build(_ wallet: SLPWallet, tokenId: String, amount: Double, toAddress: String) throws -> SLPTransactionBuilderResponse {
        
        let minSatoshisForToken = UInt64(546)
        var satoshisForTokens: UInt64 = minSatoshisForToken
        let satoshisForInput = 148 + 200
        var tokenInputs = 1
        var privKeys = [PrivateKey]()
        var newUTXOs = [SLPWalletUTXO]()
        var usedUTXOs = [SLPWalletUTXO]()
        
        guard let token = wallet.tokens[tokenId] else {
            // Token doesn't exist
            throw SLPTransactionBuilderError.TOKEN_NOT_FOUND
        }
        
        guard let decimal = token.decimal else {
            throw SLPTransactionBuilderError.DECIMAL_NOT_AVAILABLE
        }
        
        guard token.getBalance() >= amount else {
            // Insufficent balance
            throw SLPTransactionBuilderError.INSUFFICIENT_FUNDS
        }
        
        // change amount
        let rawTokenAmount = TokenQtyConverter.convertToRawQty(amount, decimal: decimal)
        
        guard let tokenId = token.tokenId
            , let tokenIdInData = Data(hex: tokenId)
            , let lokadIdInData = Data(hex: "534c5000")
            , let tokenTypeInData = Data(hex: "01")
            , let actionInData = "SEND".data(using: String.Encoding.ascii) else {
                throw SLPTransactionBuilderError.CONVERSION_METADATA
        }
        
        guard let amountInData = TokenQtyConverter.convertToData(rawTokenAmount) else {
            throw SLPTransactionBuilderError.CONVERSION_AMOUNT
        }
        
        let newScript = try Script()
            .append(.OP_RETURN)
            .appendData(lokadIdInData)
            .appendData(tokenTypeInData)
            .appendData(actionInData)
            .appendData(tokenIdInData)
            .appendData(amountInData)
        
        // I can start to create my transaction here :)
        
        // UTXOs selection from SLPTokenUTXOs
        var sum = 0
        var selectedTokenUTXOs: [SLPTokenUTXO] = token.utxos
            .filter { utxo -> Bool in
                guard sum < rawTokenAmount
                    , let privKey = wallet.getPrivKeyByCashAddress(utxo.cashAddress) else {
                    return false
                }
                
                privKeys.append(privKey)
                sum += utxo.rawTokenQty
                return true
            }
            .compactMap { $0 }
        
        let rawTokenChange = sum - rawTokenAmount
        
        // Case we don't have the PrivKey of utxos and didn't get enough tokens
        if rawTokenChange < 0 {
            throw SLPTransactionBuilderError.INSUFFICIENT_FUNDS
        }
        
        if rawTokenChange > 0 {
            guard let changeInData = TokenQtyConverter.convertToData(rawTokenChange) else {
                // throw an exception
                throw SLPTransactionBuilderError.CONVERSION_CHANGE
            }
            
            try newScript.appendData(changeInData)
            satoshisForTokens += minSatoshisForToken
            tokenInputs += 1
        }
        
        usedUTXOs.append(contentsOf: selectedTokenUTXOs)
        var selectedUTXOs = selectedTokenUTXOs.map({ utxo -> UnspentTransaction in
            return utxo.asUnspentTransaction()
        })

        guard let tokenChangeAddress = try? AddressFactory.create(wallet.SLPAccount.cashAddress) else {
            throw SLPTransactionBuilderError.WALLET_ADDRESS_INVALID
        }
        
        guard let lockScriptTokenChange = Script(address: tokenChangeAddress) else {
            // throw exception
            throw SLPTransactionBuilderError.SCRIPT_TOKEN_CHANGE
        }

        guard let cashChangeAddress = try? AddressFactory.create(wallet.BCHAccount.cashAddress) else {
            throw SLPTransactionBuilderError.WALLET_ADDRESS_INVALID
        }
        
        guard let lockScriptCashChange = Script(address: cashChangeAddress) else {
            // throw exception
            throw SLPTransactionBuilderError.SCRIPT_CHANGE
        }

        guard let toAddress = try? AddressFactory.create(toAddress) else {
            throw SLPTransactionBuilderError.TO_ADDRESS_INVALID
        }
        
        guard let lockScriptTo = Script(address: toAddress) else {
            // throw exception
            throw SLPTransactionBuilderError.SCRIPT_TO
        }
        
        
        let opOutput = TransactionOutput(value: 0, lockingScript: newScript.data)
        let toOutput = TransactionOutput(value: minSatoshisForToken, lockingScript: lockScriptTo.data)
        
        var outputs: [TransactionOutput] = [opOutput, toOutput]
        
        if rawTokenChange > 0 {
            let tokenChangeOutput = TransactionOutput(value: minSatoshisForToken, lockingScript: lockScriptTokenChange.data)
            outputs.append(tokenChangeOutput)
        }
        
        let totalAmount: UInt64 = selectedUTXOs.reduce(0) { $0 + $1.output.value }
        
        // 9 = 8 + 1 unsigned Int quantity of tokens
        // 9 = value of OP_RETURN (same as previously)
        // 46 = value of OP_RETURN data
        // 34 = value of output
        // 148 = value of input + 200 for propagation
        
        let txFee = UInt64(selectedUTXOs.count * satoshisForInput + outputs.count * 34 + 46 + 9 * tokenInputs + 9)
        var change: Int64 = Int64(totalAmount) - Int64(satoshisForTokens) - Int64(txFee)
        
        // If there is not enough gas, lets grab utxos from the wallet to refill
        if change < 0 {
            var sum = Int(change)
            let gasTokenUTXOs: [SLPWalletUTXO] = wallet.utxos
                .filter { utxo -> Bool in
                    guard sum < 0
                        , let privKey = wallet.getPrivKeyByCashAddress(utxo.cashAddress) else {
                            return false
                    }
                    privKeys.append(privKey)
                    
                    sum = sum + Int(utxo.satoshis) - satoshisForInput // Minus the future fee for an input
                    return true
                }
                .compactMap { $0 }
            
            let gasUTXOs = gasTokenUTXOs.map({ utxo -> UnspentTransaction in
                return utxo.asUnspentTransaction()
            })
            
            let gas: Int64 = Int64(gasUTXOs.reduce(0) { $0 + $1.output.value })
            
            change = change + gas
            
            if change < 0 {
                // Throw exception not enough gas
                throw SLPTransactionBuilderError.GAS_INSUFFICIENT
            }
            
            // Add my gasUTXOs in my selectedUTXOs
            selectedUTXOs.append(contentsOf: gasUTXOs)
            usedUTXOs.append(contentsOf: gasTokenUTXOs)
        }
        
        let unsignedInputs = selectedUTXOs.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        
        if change > minSatoshisForToken { // Minimum for expensable utxo
            let changeOutput = TransactionOutput(value: UInt64(change), lockingScript: lockScriptCashChange.data)
            outputs.append(changeOutput)
        }
        
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        let unsignedTx = UnsignedTransaction(tx: tx, utxos: selectedUTXOs)
        
        
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }
        
        // Signing
        let hashType = SighashType.BCH.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: privKeys[i])
            let txin = inputsToSign[i]
            let pubkey = privKeys[i].publicKey()
            
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            
            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
        }
        
        let signedTx = transactionToSign.serialized()
        
        //
        // Check Destination
        //
        
        if toAddress.cashaddr == tokenChangeAddress.cashaddr {
            let newUTXO = SLPTokenUTXO(unsignedTx.tx.txID, satoshis: Int64(minSatoshisForToken), cashAddress: tokenChangeAddress.cashaddr, scriptPubKey: lockScriptTo.hex, index: 1, rawTokenQty: rawTokenAmount)
            newUTXO._isValid = true
            newUTXOs.append(newUTXO)
        }
        
        if toAddress.cashaddr == cashChangeAddress.cashaddr {
            let newUTXO = SLPWalletUTXO(unsignedTx.tx.txID, satoshis: Int64(minSatoshisForToken), cashAddress: cashChangeAddress.cashaddr, scriptPubKey: lockScriptTo.hex, index: 1)
            newUTXOs.append(newUTXO)
        }
        
        //
        // Check Change
        //
        
        var index = 2
        if rawTokenChange > 0 {
            let newUTXO = SLPTokenUTXO(unsignedTx.tx.txID, satoshis: Int64(minSatoshisForToken), cashAddress: tokenChangeAddress.cashaddr, scriptPubKey: lockScriptTokenChange.hex, index: index, rawTokenQty: rawTokenChange)
            newUTXO._isValid = true
            newUTXOs.append(newUTXO)
            index += 1
        }
        
        if change > minSatoshisForToken { // Minimum for expensable utxo
            let newUTXO = SLPWalletUTXO(unsignedTx.tx.txID, satoshis: Int64(change), cashAddress: cashChangeAddress.cashaddr, scriptPubKey: lockScriptCashChange.hex, index: index)
            newUTXOs.append(newUTXO)
        }

        // Return rawTx, inputs used, new outputs
        return SLPTransactionBuilderResponse(rawTx: signedTx.hex, usedUTXOs: usedUTXOs, newUTXOs: newUTXOs)
    }
}
