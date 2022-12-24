//
//  Extention + AlertController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 24.12.2022.
//

import UIKit

extension UIAlertController {
    func makeWallet(completion: @escaping (String, Double) -> Void) {
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let name = self.textFields?.first?.text else { return}
            guard !name.isEmpty else { return }
            
            guard let textValue = self.textFields?.last?.text else { return }
            guard let value = Double(textValue) else { return }
            
            completion(name, value)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "Wallet name"
        }
        addTextField { textField in
            textField.placeholder = "Amount of money"
        }
    }
    
    func addCategory(completion: @escaping (String) -> Void) {
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let name = self.textFields?.first?.text else { return }
            guard !name.isEmpty else { return }
            
            completion(name)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "Write name of category"
            
        }
    }
}
