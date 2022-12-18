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
            
            DispatchQueue.main.async {
                StorageManager.shared.createTotal(total: total)
                StorageManager.shared.saveNewWallet(wallet: initialWallet, total: total)
            }
        }
    }
    
    
}
