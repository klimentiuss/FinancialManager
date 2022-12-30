//
//  Wallet.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

class Total: Object {
    @Persisted(primaryKey: true) var id = 0
    @Persisted var name = "Total"
    @Persisted var value: Double = 0
    
    @Persisted var wallets: List<Wallet>
    @Persisted var transactions: List<Transaction>
}

class Wallet: Object {
    @Persisted var name = ""
    @Persisted var money: Double = 0

    @Persisted var transactions: List<Transaction>
}

class Transaction: Object {
    @Persisted var value: Double = 0
    @Persisted var type = ""
    @Persisted var date = ""
    @Persisted var note = ""
    @Persisted var category: Category?
    @Persisted var wallet: Wallet?
    @Persisted var image: Data? 
}

class Category: Object {
    @Persisted var name = ""
}


