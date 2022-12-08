//
//  Wallet.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

class Wallet: Object {
    @Persisted var name = ""
    @Persisted var money: Double = 0

    @Persisted var transactions: List<Transaction>
}

class Transaction: Object {
    @Persisted var value: Double = 0
    @Persisted var type = ""
    @Persisted var date = ""
}
