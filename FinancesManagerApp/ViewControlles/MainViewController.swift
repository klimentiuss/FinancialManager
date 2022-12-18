//
//  ViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

class MainViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var walletTextField: UITextField!
    
    //MARK: - Private properties
    private let pickerView = UIPickerView()
    private var wallets: [Wallet] = []
    private var total: Total?
    
    //MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.createDefaultObjects()
        createPickerView()        
        
        DispatchQueue.main.async {
            self.total = StorageManager.shared.realm.object(ofType: Total.self, forPrimaryKey: 0)
            self.updateWallets()
        }
    }
    
    //MARK: - IBActions
    @IBAction func addWalletPressed() {
        showAlert(title: "Add new Wallet")
    }
    
    @IBAction func unwindForTransactionVC (_ sender: UIStoryboardSegue) {
    }
}


    //MARK: - Extensions
extension MainViewController {
    private func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.makeWallet { name, value in
            self.saveWallet(with: name, and: value)
            self.valueLabel.text = String(value)
            self.walletTextField.text = name
        }
        present(alert, animated: true)
    }
    
    private func saveWallet(with name: String, and value: Double) {
        let newWallet = Wallet()
        guard let mainTotal = total else { return }
        
        newWallet.name = name
        newWallet.money = value
        
        DispatchQueue.main.async {
            StorageManager.shared.saveNewWallet(wallet: newWallet, total: mainTotal)
            StorageManager.shared.updateTotal(total: mainTotal)
            self.updateWallets()
        }
    }
    
    
}

    //MARK: - Work with UIAlertController
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

    //MARK: - Work with PickerView
extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func createPickerView() {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        walletTextField.inputView = pickerView
        walletTextField.inputAccessoryView = toolBar
        pickerView.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
    }
    
    private func updateWallets() {
        let walletfromTotal = Wallet()
        walletfromTotal.name = total?.name ?? "error"
        walletfromTotal.money = total?.value ?? 0
        
        let realmWallets = StorageManager.shared.realm.objects(Wallet.self)
        wallets = []
        
        for wallet in realmWallets {
            wallets.append(wallet)
        }
        wallets.insert(walletfromTotal, at: 0)
    }
    
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
