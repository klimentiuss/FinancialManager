//
//  ViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var walletTextField: UITextField!
    
    private var wallets: Results<Wallet>!
    private let pickerView = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.createMainWallet()
        
        wallets = StorageManager.shared.realm.objects(Wallet.self)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        walletTextField.inputView = pickerView
        pickerView.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
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

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        wallets.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         let wallet = wallets[row]
        return wallet.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let wallet = wallets[row]
        walletTextField.text = wallet.name
        valueLabel.text = "\(wallet.money)"
        walletTextField.resignFirstResponder()
        print(wallet.name)
        print(wallet.money)
        
    }
    
}
