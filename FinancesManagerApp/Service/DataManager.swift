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
    
    
    
    func createMainWallet() {
        
        if !UserDefaults.standard.bool(forKey: "done") {
            UserDefaults.standard.set(true, forKey: "done")
            
            let mainWallet = Wallet()
            mainWallet.name = "Main Wallet"
            mainWallet.money = 0
            
            DispatchQueue.main.async {
                StorageManager.shared.saveNewWallet(wallet: mainWallet)
            }
        }
    }
    
    
}
