//
//  StorageManager.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    let realm = try! Realm()
    
    
    func saveNewWallet(wallet: Wallet) {
        write {
            realm.add(wallet)
        }
    }

    func addTransaction(wallet: Wallet, transaction: Transaction) {
        write {
            if transaction.type == "income" {
                wallet.money += transaction.value
            } else {
                wallet.money -= transaction.value
            }
            wallet.transactions.append(transaction)
        }
    }
  

    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error)
        }
    }
    
}
