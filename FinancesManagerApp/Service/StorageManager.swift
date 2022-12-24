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
    
    func createTotal(total: Total) {
        write {
            realm.add(total)
        }
    }
    
    func saveNewWallet(wallet: Wallet, total: Total) {
        write {
            realm.add(wallet)
            total.wallets.append(wallet)
        }
    }
    
    func updateTotal(total: Total) {
        write {
            total.value = 0
            for wallet in total.wallets {
                total.value += wallet.money
            }
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
  
    func makeDefaultCategories(categories: [Category]) {
        write {
            realm.add(categories)
        }
    }
    
    func saveNewCategory(category: Category) {
        write {
            realm.add(category)
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
