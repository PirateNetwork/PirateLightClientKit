//
//  ZcashRustBackendWelding.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 12/09/2019.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation

enum RustWeldingError: Error {
    case genericError(message: String)
    case dataDbInitFailed(message: String)
    case dataDbNotEmpty
    case saplingSpendParametersNotFound
    case malformedStringInput
    case noConsensusBranchId(height: Int32)
    case unableToDeriveKeys
}

enum ZcashRustBackendWeldingConstants {
    static let validChain: Int32 = -1
}

/**
    Enumeration of potential return states for database initialization. If `seedRequired` is returned, the caller must
    re-attempt initialization providing the seed
 */
public enum DbInitResult {
    case success
    case seedRequired
}

protocol ZcashRustBackendWelding {
    /**
    gets the latest error if available. Clear the existing error
    */
    static func lastError() -> RustWeldingError?

    /**
    gets the latest error message from librustzcash. Does not clear existing error
    */
    static func getLastError() -> String?

    /**
    initializes the data db
    - Parameter dbData: location of the data db sql file
    */
    static func initDataDb(dbData: URL, seed: [UInt8]?, networkType: NetworkType) throws -> DbInitResult
    
    /**
    - Returns: true when the address is valid. Returns false in any other case
    - Throws: Error when the provided address belongs to another network
    */
    static func isValidSaplingAddress(_ address: String, networkType: NetworkType) throws -> Bool
    
    /**
    - Returns: true when the address is valid and transparent. false in any other case
    - Throws: Error when the provided address belongs to another network
    */
    static func isValidTransparentAddress(_ address: String, networkType: NetworkType) throws -> Bool

    /// validates whether a string encoded address is a valid Unified Address.
    /// - Returns: true when the address is valid and transparent. false in any other case
    /// - Throws: Error when the provided address belongs to another network
    static func isValidUnifiedAddress(_ address: String, networkType: NetworkType) throws -> Bool
    
    /**
    - Returns: `true` when the Sapling Extended Full Viewing Key is valid. `false` in any other case
    - Throws: Error when there's another problem not related to validity of the string in question
    */
    static func isValidSaplingExtendedFullViewingKey(_ key: String, networkType: NetworkType) throws -> Bool

    /// - Returns: `true` when the Sapling Extended Spending Key is valid, false in any other case.
    /// - Throws: Error when the key is semantically valid  but it belongs to another network
    /// - parameter key: String encoded Extendeed Spending Key
    /// - parameter networkType: `NetworkType` signaling testnet or mainnet
    static func isValidSaplingExtendedSpendingKey(_ key: String, networkType: NetworkType) throws -> Bool

    /**
    - Returns: true when the encoded string is a valid UFVK. false in any other case
    - Throws: Error when there's another problem not related to validity of the string in question
    */
    static func isValidUnifiedFullViewingKey(_ ufvk: String, networkType: NetworkType) throws -> Bool

    /**
    initialize the accounts table from a given seed and a number of accounts
    - Parameters:
        - dbData: location of the data db
        - seed: byte array of the zip32 seed
        - accounts: how many accounts you want to have
    */
    static func initAccountsTable(dbData: URL, seed: [UInt8], accounts: Int32, networkType: NetworkType) -> [SaplingExtendedSpendingKey]?
    
    /**
    initialize the accounts table from a set of unified full viewing keys
    - Parameters:
        - dbData: location of the data db
        - ufvks: an array of UnifiedFullViewingKeys
    */
    static func initAccountsTable(dbData: URL, ufvks: [UnifiedFullViewingKey], networkType: NetworkType) throws -> Bool

    /**
    initialize the blocks table from a given checkpoint (birthday)
    - Parameters:
        - dbData: location of the data db
        - height: represents the block height of the given checkpoint
        - hash: hash of the merkle tree
        - time: in milliseconds from reference
        - saplingTree: hash of the sapling tree
    */
    // swiftlint:disable function_parameter_count
    static func initBlocksTable(
        dbData: URL,
        height: Int32,
        hash: String,
        time: UInt32,
        saplingTree: String,
        networkType: NetworkType
    ) throws

    /**
    gets the address from data db from the given account
    - Parameters:
        - dbData: location of the data db
        - account: index of the given account
        - Returns: an optional string with the address if found
    */
    static func getAddress(dbData: URL, account: Int32, networkType: NetworkType) -> String?

    /**
    get the (unverified) balance from the given account
    - Parameters:
        - dbData: location of the data db
        - account: index of the given account
    */
    static func getBalance(dbData: URL, account: Int32, networkType: NetworkType) -> Int64

    /**
    get the verified balance from the given account
    - Parameters:
        - dbData: location of the data db
        - account: index of the given account
    */
    static func getVerifiedBalance(dbData: URL, account: Int32, networkType: NetworkType) -> Int64
    
    /**
    Get the verified cached transparent balance for the given address
    */
    static func getVerifiedTransparentBalance(dbData: URL, address: String, networkType: NetworkType) throws -> Int64
    
    /**
    Get the verified cached transparent balance for the given address
    */
    static func getTransparentBalance(dbData: URL, address: String, networkType: NetworkType) throws -> Int64

    /**
    get received memo from note
    - Parameters:
        - dbData: location of the data db file
        - idNote: note_id of note where the memo is located
    */
    @available(*, deprecated, message: "This function will be deprecated soon. Use `getReceivedMemo(dbData:idNote:networkType)` instead")
    static func getReceivedMemoAsUTF8(dbData: URL, idNote: Int64, networkType: NetworkType) -> String?

    /**
    get received memo from note
    - Parameters:
        - dbData: location of the data db file
        - idNote: note_id of note where the memo is located
    */
    static func getReceivedMemo(dbData: URL, idNote: Int64, networkType: NetworkType) -> Memo?
    
    /**
    get sent memo from note
    - Parameters:
        - dbData: location of the data db file
        - idNote: note_id of note where the memo is located
    */
    @available(*, deprecated, message: "This function will be deprecated soon. Use `getSentMemo(dbData:idNote:networkType)` instead")
    static func getSentMemoAsUTF8(dbData: URL, idNote: Int64, networkType: NetworkType) -> String?

    /**
    get sent memo from note
    - Parameters:
        - dbData: location of the data db file
        - idNote: note_id of note where the memo is located
    */
    static func getSentMemo(dbData: URL, idNote: Int64, networkType: NetworkType) -> Memo?
    
    /**
    Checks that the scanned blocks in the data database, when combined with the recent
    `CompactBlock`s in the cache database, form a valid chain.
    This function is built on the core assumption that the information provided in the
    cache database is more likely to be accurate than the previously-scanned information.
    This follows from the design (and trust) assumption that the `lightwalletd` server
    provides accurate block information as of the time it was requested.
        - Returns:
            * `-1` if the combined chain is valid.
            * `upper_bound` if the combined chain is invalid.
            * `upper_bound` is the height of the highest invalid block (on the assumption that the highest block in the cache database is correct).
            * `0` if there was an error during validation unrelated to chain validity.
    - Important: This function does not mutate either of the databases.
    */
    static func validateCombinedChain(dbCache: URL, dbData: URL, networkType: NetworkType) -> Int32
    
    /**
    Returns the nearest height where a rewind is possible. Currently prunning gets rid of sapling witnesses older
    than 100 blocks. So in order to reconstruct the witness tree that allows to spend notes from the given wallet
    the rewind can't be more than 100 block or back to the oldest unspent note that this wallet contains.
    - Parameters:
        - dbData: location of the data db file
        - height: height you would like to rewind to.
    */
    static func getNearestRewindHeight(dbData: URL, height: Int32, networkType: NetworkType) -> Int32

    /**
    rewinds the compact block storage to the given height. clears up all derived data as well
    - Parameters:
        - dbData: location of the data db file
        - height: height to rewind to. DON'T PASS ARBITRARY HEIGHT. Use getNearestRewindHeight when unsure
    */
    static func rewindToHeight(dbData: URL, height: Int32, networkType: NetworkType) -> Bool
    
    /**
    Scans new blocks added to the cache for any transactions received by the tracked
    accounts.
    This function pays attention only to cached blocks with heights greater than the
    highest scanned block in `db_data`. Cached blocks with lower heights are not verified
    against previously-scanned blocks. In particular, this function **assumes** that the
    caller is handling rollbacks.
    For brand-new light client databases, this function starts scanning from the Sapling
    activation height. This height can be fast-forwarded to a more recent block by calling
    [`zcashlc_init_blocks_table`] before this function.
    Scanned blocks are required to be height-sequential. If a block is missing from the
    cache, an error will be signalled.
     
    - Parameters:
        - dbCache: location of the compact block cache db
        - dbData:  location of the data db file
        - limit: scan up to limit blocks. pass 0 to set no limit.
    returns false if fails to scan.
    */
    static func scanBlocks(dbCache: URL, dbData: URL, limit: UInt32, networkType: NetworkType) -> Bool

    /**
    puts a UTXO into the data db database
    - Parameters:
        - dbData: location of the data db file
        - txid: the txid bytes for the UTXO
        - index: the index of the UTXO
        - value: the value of the UTXO
        - height: the mined height for the UTXO
    - Returns: true if the operation succeded or false otherwise
    */
    static func putUnspentTransparentOutput(
        dbData: URL,
        txid: [UInt8],
        index: Int,
        script: [UInt8],
        value: Int64,
        height: BlockHeight,
        networkType: NetworkType
    ) throws -> Bool
    
    /**
    clears the cached utxos for the given address from the specified height on
    - Parameters:
        - dbData: location of the data db file
        - address: the address of the UTXO
        - sinceheight: clear the UXTOs from that address on
    - Returns: the amount of UTXOs cleared or -1 on error
    */
    static func clearUtxos(dbData: URL, address: String, sinceHeight: BlockHeight, networkType: NetworkType) throws -> Int32

    /**
    Gets the balance of the previously downloaded UTXOs
    - Parameters:
        - dbData: location of the data db file
        - address: the address of the UTXO
    - Returns: the wallet balance containing verified and total balance.
    - Throws: Rustwelding Error if something fails
    */
    static func downloadedUtxoBalance(dbData: URL, address: String, networkType: NetworkType) throws -> WalletBalance
    
    /**
    Scans a transaction for any information that can be decrypted by the accounts in the
    wallet, and saves it to the wallet.

    - Parameters:
        - dbData: location of the data db file
        - tx:     the transaction to decrypt
        - minedHeight: height on which this transaction was mined. this is used to fetch the consensus branch ID.
    returns false if fails to decrypt.
    */
    static func decryptAndStoreTransaction(
        dbData: URL,
        txBytes: [UInt8],
        minedHeight: Int32,
        networkType: NetworkType
    ) -> Bool
    
    /**
    Creates a transaction to the given address from the given account
    - Parameters:
        - dbData: URL for the Data DB
        - account: the account index that will originate the transaction
        - extsk: extended spending key string
        - to: recipient address
        - value: transaction amount in Zatoshi
        - memo: the memo string for this transaction
        - spendParamsPath: path escaped String for the filesystem locations where the spend parameters are located
        - outputParamsPath: path escaped String for the filesystem locations where the output parameters are located
    */
    // swiftlint:disable function_parameter_count
    static func createToAddress(
        dbData: URL,
        account: Int32,
        extsk: String,
        to address: String,
        value: Int64,
        memo: MemoBytes,
        spendParamsPath: String,
        outputParamsPath: String,
        networkType: NetworkType
    ) -> Int64
    
    /**
    Creates a transaction to shield all found UTXOs in cache db.
    - Parameters:
        - dbCache: URL for the Cache DB
        - dbData: URL for the Data DB
        - account: the account index that will originate the transaction
        - xprv: transparent account private key for the transparent funds that will be shielded.
        - memo: the memo string for this transaction
        - spendParamsPath: path escaped String for the filesystem locations where the spend parameters are located
        - outputParamsPath: path escaped String for the filesystem locations where the output parameters are located
    */
    // swiftlint:disable function_parameter_count
    static func shieldFunds(
        dbCache: URL,
        dbData: URL,
        account: Int32,
        xprv: String,
        memo: MemoBytes,
        spendParamsPath: String,
        outputParamsPath: String,
        networkType: NetworkType
    ) -> Int64
    
    /**
    Derives a full viewing key from a seed
    - Parameter spendingKey: a string containing the spending key
    - Returns: the derived key
    - Throws: RustBackendError if fatal error occurs
    */
    static func deriveSaplingExtendedFullViewingKey(_ spendingKey: SaplingExtendedSpendingKey, networkType: NetworkType) throws -> SaplingExtendedFullViewingKey?

    /**
    Derives a set of full viewing keys from a seed
    - Parameter spendingKey: a string containing the spending key
    - Parameter accounts: the number of accounts you want to derive from this seed
    - Returns: an array containing the derived keys
    - Throws: RustBackendError if fatal error occurs
    */
    static func deriveSaplingExtendedFullViewingKeys(seed: [UInt8], accounts: Int32, networkType: NetworkType) throws -> [SaplingExtendedFullViewingKey]?
    
    /**
    Derives a set of Extended Spending Keys from a seed
    - Parameter seed: a string containing the seed
    - Parameter accounts: the number of accounts you want to derive from this seed
    - Returns: an array containing the spending keys
    - Throws: RustBackendError if fatal error occurs
    */
    static func deriveSaplingExtendedSpendingKeys(seed: [UInt8], accounts: Int32, networkType: NetworkType) throws -> [SaplingExtendedSpendingKey]?
    
    /**
    Derives a unified address from a seed
    - Parameter seed: an array of bytes of the seed
    - Parameter accountIndex: the index of the account you want the address for
    - Returns: an optional String containing Unified Address
    - Throws: RustBackendError if fatal error occurs
    */
    static func deriveUnifiedAddressFromSeed(seed: [UInt8], accountIndex: Int32, networkType: NetworkType) throws -> String?
    
    /**
    Derives a unified address from a Unified Full Viewing Key
    - Parameter ufvk: a string containing the extended full viewing key
    - Returns: an optional String containing the Shielded address
    - Throws: RustBackendError if fatal error occurs
    */
    static func deriveUnifiedAddressFromViewingKey(_  ufvk: String, networkType: NetworkType) throws -> String?


    /// Derives a transparent address from seed bytes
    /// - Parameter seed: an array of bytes of the seed
    /// - Parameter account: account number
    /// - Parameter index: diversifier index
    /// - Returns: an optional String containing the transparent address
    /// - Throws: RustBackendError if fatal error occurs
    static func deriveTransparentAddressFromSeed(seed: [UInt8], account: Int, index: Int, networkType: NetworkType) throws -> String?
    
    /**
    Derives a transparent account private key from Seed
    - Parameter seed: an array of bytes containing the seed
    - Returns: an optional String containing the transparent secret (private) key
    */
    static func deriveTransparentAccountPrivateKeyFromSeed(seed: [UInt8], account: Int, networkType: NetworkType) throws -> String?
    
    /**
    Derives a transparent address from a secret key
    - Parameter tsk: a hex string containing the Secret Key
    - Returns: an optional String containing the transparent address.
    */
    static func deriveTransparentAddressFromAccountPrivateKey(_ tsk: String, index: Int, networkType: NetworkType) throws -> String?
    
    /**
    Derives a tranparent address from a public key
    - Parameter pubkey: public key represented as a string
    */
    static func derivedTransparentAddressFromPublicKey(_ pubkey: String, networkType: NetworkType) throws -> String
    
    static func deriveUnifiedFullViewingKeyFromSeed(_ seed: [UInt8], numberOfAccounts: Int32, networkType: NetworkType) throws -> [UnifiedFullViewingKey]


    /// Obtains the available receiver typecodes for the given String encoded Unified Address
    /// - Parameter address: public key represented as a String
    /// - Returns  the `[UInt32]` that compose the given UA
    /// - Throws `RustWeldingError.malformedStringInput` when the UA is either invalid or malformed
    static func receiverTypecodesOnUnifiedAddress(_ address: String) throws -> [UInt32]

    /**
    Gets the consensus branch id for the given height
    - Parameter height: the height you what to know the branch id for
    */
    static func consensusBranchIdFor(height: Int32, networkType: NetworkType) throws -> Int32
}
