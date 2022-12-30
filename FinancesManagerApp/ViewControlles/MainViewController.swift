//
//  ViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

protocol MainViewControllerDelegate {
    func getTransaction() -> Transaction
}

class MainViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var walletTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Private properties
    private let pickerView = UIPickerView()
    private var wallets: [Wallet] = []
    private var total: Total?
    private var walletTransactions: List<Transaction>!
    private var totalTransactions: Results<Transaction>!
    private var isSelected = true
    
    //MARK: - LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        isSelected = true
        
        DispatchQueue.main.async {
            self.updateWallets()
            self.showTotal()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        DataManager.shared.createDefaultObjects()
        createPickerView()
        totalTransactions = StorageManager.shared.realm.objects(Transaction.self)
        
        DispatchQueue.main.async {
            self.total = StorageManager.shared.realm.object(ofType: Total.self, forPrimaryKey: 0)
            self.updateWallets()
            self.showTotal()
        }
        
        addButton.layer.borderWidth = 2
        addButton.layer.borderColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transactionVC" {
            guard let transactionVC = segue.destination as? TransactionViewController else { return }
            transactionVC.delegate = self
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
    
    private func updateWallets() {
        let realmWallets = StorageManager.shared.realm.objects(Wallet.self)
        wallets = []
        
        for wallet in realmWallets {
            wallets.append(wallet)
        }
    }
    
    private func showTotal() {
        valueLabel.text = "\(Int(total?.value ?? 0))"
        walletTextField.text = total?.name
    }
}

//MARK: - Work with PickerView
extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func createPickerView() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPressed))
        cancelButton.tintColor = #colorLiteral(red: 0.998930037, green: 0.2212841809, blue: 0.1201847121, alpha: 1)
        
        let showTotal = UIBarButtonItem(title: "Show Total", style: .plain, target: nil, action: #selector(showTotalPressed))
        showTotal.tintColor = #colorLiteral(red: 0.1380040646, green: 0.768296361, blue: 0, alpha: 1)
        
        let selectButton = UIBarButtonItem(title: "Select", style: .done, target: nil, action: #selector(selectWalletPressed))
        selectButton.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancelButton, flexible, showTotal, selectButton], animated: true)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        walletTextField.inputView = pickerView
        walletTextField.inputAccessoryView = toolbar
        
        pickerView.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    }
    
    @objc private func selectWalletPressed() {
        pickerView.selectRow(0, inComponent: 0, animated: true)
        pickerView(pickerView, didSelectRow: 0, inComponent: 0)
    }
    
    private func createToolbarText(title: String) -> UIBarButtonItem {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.text = title
        label.center = CGPoint(x: CGRectGetMidX(view.frame), y: view.frame.height)
        let toolbarTitle = UIBarButtonItem(customView: label)
        return toolbarTitle
    }
    
    @objc private func showTotalPressed() {
        isSelected = true
        showTotal()
        
        tableView.reloadData()
        self.view.endEditing(true)
    }
    
    @objc private func cancelPressed() {
        self.view.endEditing(true)
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
        
        walletTransactions = wallet.transactions
        isSelected = false
        tableView.reloadData()
    }
}

//MARK: - Work with Table view

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSelected ? totalTransactions.count : walletTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        let transaction: Transaction
        
        if isSelected {
            transaction = totalTransactions.reversed()[indexPath.row]
        } else {
            transaction = walletTransactions.reversed()[indexPath.row]
        }
        
        cell.categoryLabel.text = (transaction.category?.name ?? "error")
        cell.walletLabel.text = (transaction.wallet?.name ?? "error")
        
        cell.valueLabel.text = transaction.type + String(transaction.value)
        
        
        switch transaction.type {
        case "+":
            cell.valueLabel.textColor = #colorLiteral(red: 0.1380040646, green: 0.768296361, blue: 0, alpha: 1)
        case "-":
            cell.valueLabel.textColor = #colorLiteral(red: 0.998930037, green: 0.2212841809, blue: 0.1201847121, alpha: 1)
        default:
            break
        }
        
        return cell
    }
    
    
}

extension MainViewController: MainViewControllerDelegate {
    func getTransaction() -> Transaction {
            let indexPathForSelectedRows = tableView.indexPathsForSelectedRows
            let indexPath = indexPathForSelectedRows?.last
            let transaction: Transaction
            if isSelected {
                transaction = totalTransactions.reversed()[indexPath?.row ?? 0]
            } else {
                transaction = walletTransactions.reversed()[indexPath?.row ?? 0]

            }
            return transaction
        }
}
