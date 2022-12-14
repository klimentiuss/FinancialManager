//
//  DataManager.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    func createDefaultObjects() {
        
        if !UserDefaults.standard.bool(forKey: "done") {
            UserDefaults.standard.set(true, forKey: "done")
            
            let initialWallet = Wallet()
            initialWallet.name = "Main Wallet"
            initialWallet.money = 0
            
            let total = Total()
            let categories: [Category] = defaultCategories()
            
            DispatchQueue.main.async {
                StorageManager.shared.createTotal(total: total)
                StorageManager.shared.saveNewWallet(wallet: initialWallet, total: total)
                StorageManager.shared.makeDefaultCategories(categories: categories)
            }
        }
    }
    
    func defaultCategories() -> [Category] {
        let categoryNames = ["0οΈβ£ Without category", "π Food", "π Travel", "π Medicine", "π¦ Bank", "πΈ Business", "π‘ Home", "ποΈ State", "π¨βπ§βπ¦ Children", "π Pets", "β¨ Beauty", "π Education", "π Π‘lothes", "π Gifts", "π‘ Entertainment", "π₯οΈ Technic", "π Transport"]
        var categories: [Category] = []
        
        for name in categoryNames {
            let category = Category()
            category.name = name
            
            categories.append(category)
        }
        
        return categories
    }
    
}
