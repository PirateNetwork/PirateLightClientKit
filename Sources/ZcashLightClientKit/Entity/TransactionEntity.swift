//
//  TransactionEntity.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 11/14/19.
//

import Foundation
import SQLite

public enum TransactionNG {

    public struct Overview {
        public let blocktime: Int64
        public let expiryHeight: BlockHeight
        public let fee: Zatoshi
        public let id: Int
        public let index: Int
        public let isWalletInternal: Bool
        public var isSentTransaction: Bool { value < Zatoshi(0) }
        public let hasChange: Bool
        public let memoCount: Int
        public let minedHeight: BlockHeight
        public let raw: Data
        public let rawID: Data
        public let receivedNoteCount: Int
        public let sentNoteCount: Int
        public let value: Zatoshi
    }

    public struct Received {
        public let blocktime: Int64
        public let expiryHeight: BlockHeight
        public let fromAccount: Int
        public let id: Int
        public let index: Int
        public let memoCount: Int
        public let minedHeight: BlockHeight
        public let noteCount: Int
        public let raw: Data
        public let rawID: Data
        public let value: Zatoshi
    }

    public struct Sent {
        public let blocktime: Int64
        public let expiryHeight: BlockHeight
        public let fromAccount: Int
        public let id: Int
        public let index: Int
        public let memoCount: Int
        public let minedHeight: BlockHeight?
        public let noteCount: Int
        public let raw: Data
        public let rawID: Data
        public let value: Zatoshi
    }
}

extension TransactionNG.Overview {
    enum Column {
        static let id = Expression<Int>("id_tx")
        static let minedHeight = Expression<BlockHeight>("mined_height")
        static let index = Expression<Int>("tx_index")
        static let rawID = Expression<Blob>("txid")
        static let expiryHeight = Expression<BlockHeight>("expiry_height")
        static let raw = Expression<Blob>("raw")
        static let value = Expression<Int64>("net_value")
        static let fee = Expression<Int64>("fee_paid")
        static let isWalletInternal = Expression<Bool>("is_wallet_internal")
        static let hasChange = Expression<Bool>("has_change")
        static let sentNoteCount = Expression<Int>("sent_note_count")
        static let receivedNoteCount = Expression<Int>("received_note_count")
        static let memoCount = Expression<Int>("memo_count")
        static let blockTime = Expression<Int64>("block_time")
    }

    init(row: Row) throws {
        self.blocktime = try row.get(Column.blockTime)
        self.expiryHeight = try row.get(Column.expiryHeight)
        self.fee = Zatoshi(try row.get(Column.fee))
        self.id = try row.get(Column.id)
        self.index = try row.get(Column.index)
        self.isWalletInternal = try row.get(Column.isWalletInternal)
        self.hasChange = try row.get(Column.hasChange)
        self.memoCount = try row.get(Column.memoCount)
        self.minedHeight = try row.get(Column.minedHeight)
        self.raw = Data(blob: try row.get(Column.raw))
        self.rawID = Data(blob: try row.get(Column.rawID))
        self.receivedNoteCount = try row.get(Column.receivedNoteCount)
        self.sentNoteCount = try row.get(Column.sentNoteCount)
        self.value = Zatoshi(try row.get(Column.value))
    }
}

extension TransactionNG.Received {
    enum Column {
        static let id = Expression<Int>("id_tx")
        static let minedHeight = Expression<BlockHeight>("mined_height")
        static let index = Expression<Int>("tx_index")
        static let rawID = Expression<Blob>("txid")
        static let expiryHeight = Expression<BlockHeight>("expiry_height")
        static let raw = Expression<Blob>("raw")
        static let fromAccount = Expression<Int>("received_by_account")
        static let value = Expression<Int64>("received_total")
        static let fee = Expression<Int64>("fee_paid")
        static let noteCount = Expression<Int>("received_note_count")
        static let memoCount = Expression<Int>("memo_count")
        static let blockTime = Expression<Int64>("block_time")
    }

    init(row: Row) throws {
        self.blocktime = try row.get(Column.blockTime)
        self.expiryHeight = try row.get(Column.expiryHeight)
        self.fromAccount = try row.get(Column.fromAccount)
        self.id = try row.get(Column.id)
        self.index = try row.get(Column.index)
        self.memoCount = try row.get(Column.memoCount)
        self.minedHeight = try row.get(Column.minedHeight)
        self.noteCount = try row.get(Column.noteCount)
        self.raw = Data(blob: try row.get(Column.raw))
        self.rawID = Data(blob: try row.get(Column.rawID))
        self.value = Zatoshi(try row.get(Column.value))
    }
}

extension TransactionNG.Sent {
    enum Column {
        static let id = Expression<Int>("id_tx")
        static let minedHeight = Expression<BlockHeight>("mined_height")
        static let index = Expression<Int>("tx_index")
        static let rawID = Expression<Blob>("txid")
        static let expiryHeight = Expression<BlockHeight>("expiry_height")
        static let raw = Expression<Blob>("raw")
        static let fromAccount = Expression<Int>("sent_from_account")
        static let value = Expression<Int64>("sent_total")
        static let fee = Expression<Int64>("fee_paid")
        static let noteCount = Expression<Int>("sent_note_count")
        static let memoCount = Expression<Int>("memo_count")
        static let blockTime = Expression<Int64>("block_time")
    }

    init(row: Row) throws {
        self.blocktime = try row.get(Column.blockTime)
        self.expiryHeight = try row.get(Column.expiryHeight)
        self.fromAccount = try row.get(Column.fromAccount)
        self.id = try row.get(Column.id)
        self.index = try row.get(Column.index)
        self.memoCount = try row.get(Column.memoCount)
        self.minedHeight = try row.get(Column.minedHeight)
        self.noteCount = try row.get(Column.noteCount)
        self.raw = Data(blob: try row.get(Column.raw))
        self.rawID = Data(blob: try row.get(Column.rawID))
        self.value = Zatoshi(try row.get(Column.value))
    }
}

/**
convenience representation of all transaction types
*/
public protocol TransactionEntity {
    /**
    Internal transaction id
    */
    var id: Int? { get set }

    /**
    Blockchain transaction id
    */
    var transactionId: Data { get set }

    /**
    String representing the date  of creation
     
    format is yyyy-MM-dd'T'HH:MM:ss.SSSSSSSSSZ
    - Example:  2019-12-04T17:49:10.636624000Z
    */
    var created: String? { get set }
    var transactionIndex: Int? { get set }
    var expiryHeight: BlockHeight? { get set }
    var minedHeight: BlockHeight? { get set }
    var raw: Data? { get set }
}

/**
Hashable extension default implementation
*/
public extension TransactionEntity {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(transactionId)
        hasher.combine(expiryHeight)
        hasher.combine(minedHeight)
        hasher.combine(raw)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard
            lhs.id == rhs.id,
            lhs.transactionId == rhs.transactionId,
            lhs.created == rhs.created,
            lhs.expiryHeight == rhs.expiryHeight,
            lhs.minedHeight == rhs.minedHeight,
            ((lhs.raw != nil && rhs.raw != nil) || (lhs.raw == nil && rhs.raw == nil))
        else { return false }
        
        if let lhsRaw = lhs.raw, let rhsRaw = rhs.raw {
            return lhsRaw == rhsRaw
        }
        
        return true
    }
    
    func anchor(network: ZcashNetwork) -> BlockHeight? {
        if let minedHeight = self.minedHeight, minedHeight != -1 {
            return max(minedHeight - ZcashSDK.defaultStaleTolerance, network.constants.saplingActivationHeight)
        }
        
        if let expiryHeight = self.expiryHeight, expiryHeight != -1 {
            return max(expiryHeight - ZcashSDK.expiryOffset - ZcashSDK.defaultStaleTolerance, network.constants.saplingActivationHeight)
        }
        
        return nil
    }
}

/**
Abstract representation of all transaction types
*/
public protocol AbstractTransaction {
    /**
    internal id for this transaction
    */
    var id: Int? { get set }

    /**
    value in zatoshi
    */
    var value: Zatoshi { get set }

    /**
    data containing the memo if any
    */
    var memo: Data? { get set }

    var fee: Zatoshi? { get set }
}

/**
Capabilites of a signed transaction
*/
public protocol SignedTransactionEntity {
    var raw: Data? { get set }
}

/**
Capabilities of an entity that can be uniquely identified by a raw transaction id
*/
public protocol RawIdentifiable {
    var rawTransactionId: Data? { get set }
}

/**
Attributes that a Mined transaction must have
*/
public protocol MinedTransactionEntity: AbstractTransaction, RawIdentifiable {
    /**
    height on which this transaction was mined at. Convention is that -1 is retuned when it has not been mined yet
    */
    var minedHeight: Int { get set }
    
    /**
    internal note id that is involved on this transaction
    */
    var noteId: Int { get set }

    /**
    block time in in reference since 1970
    */
    var blockTimeInSeconds: TimeInterval { get set }

    /**
    internal index for this transaction
    */
    var transactionIndex: Int { get set }
}

public protocol ConfirmedTransactionEntity: MinedTransactionEntity, SignedTransactionEntity {
    /**
    recipient address if available
    */
    var toAddress: String? { get set }

    /**
    expiration height for this transaction
    */
    var expiryHeight: BlockHeight? { get set }
}

public extension ConfirmedTransactionEntity {
    var isOutbound: Bool {
        self.toAddress != nil
    }
    
    var isInbound: Bool {
        self.toAddress == nil
    }
    
    var blockTimeInMilliseconds: Double {
        self.blockTimeInSeconds * 1000
    }
}

public extension AbstractTransaction {
    var intValue: Int {
        Int(self.value.amount)
    }
}
