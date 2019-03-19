//
//  SLPTransactionBuilder.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/04.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import BitcoinKit

class SLPTransactionBuilder {
    
    enum SLPTransactionBuilderError: String, Error {
        case TOKEN_NOT_FOUND = "Token does not exist"
        case INSUFFICIENT_FUNDS = "Insufficent funds available"
        case CONVERSION_METADATA = "Failed to encode metadata"
        case CONVERSION_AMOUNT = "Failed to convert token amount"
        case CONVERSION_CHANGE = "Failed to convert change"
        case SCRIPT_TO = "Failed to create to address script"
        case SCRIPT_TOKEN_CHANGE = "Failed to create token change script"
        case GAS_INSUFFICIENT = "Insufficient BCH available for transaction"
        case SCRIPT_CHANGE = "Failed to create BCH change script"
        case DECIMAL_NOT_AVAILABLE = "Decimal values not available"
    }
    
    static func build(_ wallet: SLPWallet, tokenId: String, amount: Double, toAddress: String) throws -> String {
        
        let minSatoshisForToken = UInt64(546)
        var satoshisForTokens: UInt64 = minSatoshisForToken
        
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
        let selectedTokenUTXOs: [SLPTokenUTXO] = token.utxos
            .filter { utxo -> Bool in
                if sum > rawTokenAmount {
                    return false
                }
                
                sum += utxo.rawTokenQty
                return true
            }
            .compactMap { $0 }
        
        let rawTokenChange = sum - rawTokenAmount
        if rawTokenChange > 0 {
            guard let changeInData = TokenQtyConverter.convertToData(rawTokenChange) else {
                // throw an exception
                throw SLPTransactionBuilderError.CONVERSION_CHANGE
            }
            
            try newScript.appendData(changeInData)
            satoshisForTokens += minSatoshisForToken
        }
        
        var selectedUTXOs = selectedTokenUTXOs.map({ utxo -> UnspentTransaction in
            return utxo.asUnspentTransaction()
        })
        
        let fromAddress = try AddressFactory.create(wallet.cashAddress)
        let toAddress = try AddressFactory.create(toAddress)
        
        let opOutput = TransactionOutput(value: 0, lockingScript: newScript.data)
        
        guard let lockScriptTo = Script(address: toAddress) else {
            // throw exception
            throw SLPTransactionBuilderError.SCRIPT_TO
        }
        
        let toOutput = TransactionOutput(value: minSatoshisForToken, lockingScript: lockScriptTo.data)
        
        var outputs: [TransactionOutput] = [opOutput, toOutput]
        
        if rawTokenChange > 0 {
            guard let lockScriptTokenChange = Script(address: fromAddress) else {
                // throw exception
                throw SLPTransactionBuilderError.SCRIPT_TOKEN_CHANGE
            }
            
            let tokenChangeOutput = TransactionOutput(value: minSatoshisForToken, lockingScript: lockScriptTokenChange.data)
            outputs.append(tokenChangeOutput)
        }
        
        let totalAmount: UInt64 = selectedUTXOs.reduce(0) { $0 + $1.output.value }
        let txFee = UInt64(selectedUTXOs.count * 200 + outputs.count * 33 + 300)
        var change: Int64 = Int64(totalAmount) - Int64(satoshisForTokens) - Int64(txFee)
        
        // If there is not enough gas, lets grab utxos from the wallet to refill
        if change < 0 {
            var sum = Int(change)
            let gasTokenUTXOs: [SLPWalletUTXO] = wallet.utxos
                .filter { utxo -> Bool in
                    if sum >= 0 {
                        return false
                    }
                    
                    sum = sum + Int(utxo.satoshis) - 200 // Minus the future fee for an input
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
        }
        
        let unsignedInputs = selectedUTXOs.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        
        if change > minSatoshisForToken { // Minimum for expensable utxo
            guard let lockScriptChange = Script(address: fromAddress) else {
                // throw exception
                throw SLPTransactionBuilderError.SCRIPT_CHANGE
            }
            
            let changeOutput = TransactionOutput(value: UInt64(change), lockingScript: lockScriptChange.data)
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
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
            
            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: wallet._privKey)
            let txin = inputsToSign[i]
            let pubkey = wallet._privKey.publicKey()
            
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            
            // TODO: sequenceの更新
            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
        }
       
        let signedTx = transactionToSign.serialized()
        
        return signedTx.hex
    }
}
