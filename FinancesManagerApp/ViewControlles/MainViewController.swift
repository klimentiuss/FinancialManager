//
//  ViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.createMainWallet()
    }

    
    @IBAction func addWalletPressed() {
        showAlert(title: "Add new Wallet")
    }
    
    @IBAction func unwindForTransactionVC (_ sender: UIStoryboardSegue) {
        
    }
}

extension MainViewController {
    private func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.makeWallet { name, value in
            self.saveWallet(with: name, and: value)
        }
        present(alert, animated: true)
    }
    
    private func saveWallet(with name: String, and value: Double) {
        let newWallet = Wallet()
        
        newWallet.name = name
        newWallet.money = value
        
        DispatchQueue.main.async {
            StorageManager.shared.saveNewWallet(wallet: newWallet)
        }
    }
}


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
}
