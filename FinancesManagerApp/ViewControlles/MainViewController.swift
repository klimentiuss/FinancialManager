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
    override func viewWillAppear(_ animated: Bool) {
       updateWallets()
       updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.createDefaultObjects()
        createPickerView()
        
        DispatchQueue.main.async {
            self.total = StorageManager.shared.realm.object(ofType: Total.self, forPrimaryKey: 0)
            self.updateWallets()
            self.updateView()
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
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
        alert.makeWallet { name, value in
            self.saveWallet(with: name, and: value)
            self.valueLabel.text = String(Int(value))
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

    //MARK: - Work with PickerView
extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func createPickerView() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPressed))
        cancelButton.tintColor = .red
        
        let toolbarTitle = createToolbarText(title: "Choose Wallet")
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([toolbarTitle, flexible, cancelButton], animated: true)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        walletTextField.inputView = pickerView
        walletTextField.inputAccessoryView = toolbar
        pickerView.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    }
    
    private func createToolbarText(title: String) -> UIBarButtonItem {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.text = title
        label.center = CGPoint(x: CGRectGetMidX(view.frame), y: view.frame.height)
        let toolbarTitle = UIBarButtonItem(customView: label)
        return toolbarTitle
    }
    
    @objc private func cancelPressed() {
        self.view.endEditing(true)
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
    
    func updateView() {
        let total = wallets.first
        valueLabel.text = "\(Int(total?.money ?? 0))"
        walletTextField.text = total?.name
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
        valueLabel.text = "\(Int(wallet.money))"
        walletTextField.resignFirstResponder()
    }
}
