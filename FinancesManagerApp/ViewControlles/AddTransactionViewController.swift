//
//  AddTransactionViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 05.12.2022.
//

import RealmSwift

class AddTransactionViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePickerTF: UITextField!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var walletTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Private Properties
    private var selectedType = "+"
    private var wallets: Results<Wallet>!
    private var selectedWallet: Wallet?
    private var selectedDate = ""
    private var selectedDay = ""
    private let datePicker = UIDatePicker()
    private let pickerView = UIPickerView()
    private var total: Total?
    var selectedCategory: Category?
    
    
    //MARK: - LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        wallets = StorageManager.shared.realm.objects(Wallet.self)
        createWalletPicker()
        createDatePicker()
                
        DispatchQueue.main.async {
            self.total = StorageManager.shared.realm.object(ofType: Total.self, forPrimaryKey: 0)
        }
        
        valueTextField.inputAccessoryView = createToolbar(action: "cancel", title: "Enter value")
        noteTextView.inputAccessoryView = createToolbar(action: "done", title: "Enter note")
        valueTextField.delegate = self
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calculatorSegue" {
            let destinationVC = segue.destination as! CalculatorViewController
            destinationVC.delegate = self
        }
        
        if segue.identifier == "categorySegue" {
            let destinationVC = segue.destination as! CategoriesTableViewController
            destinationVC.delegate = self
        }
    }
    
    //MARK: - IBActions
    @IBAction func uploadPressed(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func segmentedControllPressed() {
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedType = "+"
            changeSegmentedTextColor(selected: typeSegmentedControl)
        default:
            selectedType = "-"
            changeSegmentedTextColor(selected: typeSegmentedControl)
        }
    }
    
    @IBAction func todayPressed() {
        selectedDay = "today"
        selectedDate = getDate()
        switchColor()
    }
    
    @IBAction func yesterdayPressed() {
        selectedDay = "yesterday"
        selectedDate = getDate()
        switchColor()
    }
    
    @IBAction func saveButtonPressed() {
        
        if valueTextField.text == "" {
            showAlert(title: "Oops, you forgot to set the value of transaction.")
        }
        if walletTextField.backgroundColor != #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) ||  categoryButton.backgroundColor != #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) {
            showAlert(title: "Oops, you forgot to set wallet or category.")
        } else {
            saveTransaction()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed() {
    }
}

extension AddTransactionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddTransactionViewController {
    //MARK: - Private Methods
    private func saveTransaction() {
        guard let wallet = selectedWallet else { return }
        guard let transaction = makeTransaction() else { return }
        
        guard let newTotal = total else { return }
        
        DispatchQueue.main.async {
            StorageManager.shared.addTransaction(total: newTotal, wallet: wallet, transaction: transaction)
            StorageManager.shared.updateTotal(total: newTotal)
        }
    }
    
    private func makeTransaction() -> Transaction? {
        
        let transaction = Transaction()
        let value = Double(valueTextField.text ?? "0") ?? 0
        let transactionImage = imageView.image
        var transactionImageData = transactionImage?.jpegData(compressionQuality: 1.0)
        if imageView.image == UIImage(systemName: "photo.artframe") {
            transactionImageData = nil
        }
        
        transaction.value = value
        transaction.type = selectedType
        transaction.note = noteTextView.text
        transaction.category = selectedCategory
        transaction.wallet = selectedWallet
        transaction.image = transactionImageData
       
        
        
        if selectedDate == "" {
            selectedDay = "today"
            transaction.date = getDate()
        } else {
            transaction.date = selectedDate
        }
        
        return transaction
    }
    
    private func getDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        var dateYouNeed = ""
        
        if selectedDay == "today" {
            dateYouNeed = dateFormatter.string(from: date)
        } else {
            dateYouNeed = dateFormatter.string(from: Date().yesterday)
        }
        
        return dateYouNeed
    }
    
    private func createWalletPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        
        walletTextField.inputView = pickerView
        walletTextField.inputAccessoryView = createToolbar(action: "cancel", title: "Choose Wallet")
    }
    
    private func createDatePicker() {
        datePickerTF.inputAccessoryView = createToolbar(action: "date", title: "Choose Date")
        datePickerTF.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
    }
    
    private func createToolbar(action: String, title: String) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        var actionButton = UIBarButtonItem()
        
        switch action {
        case "done":
            actionButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(cancelPressed))
            actionButton.tintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        case "date":
            actionButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
            actionButton.tintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        default:
            actionButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPressed))
            actionButton.tintColor = .red
        }
        
        let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.text = title
        label.center = CGPoint(x: CGRectGetMidX(view.frame), y: view.frame.height)
        let toolbarTitle = UIBarButtonItem(customView: label)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([toolbarTitle, flexible, actionButton], animated: true)
        
        return toolbar
    }
    @objc private func cancelPressed() {
        self.view.endEditing(true)
    }
    
    @objc private func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "dd/MM/yy"
        
        datePickerTF.text = formatter.string(from: datePicker.date)
        selectedDate = datePickerTF.text ?? "0"
        selectedDay = "otherDay"
        switchColor()
        self.view.endEditing(true)
    }
    
    private func switchColor() {
        
        switch selectedDay {
        case "today":
            todayButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            todayButton.configuration?.titleTextAttributesTransformer = changeColor(color: "white")
            yesterdayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            yesterdayButton.configuration?.titleTextAttributesTransformer = changeColor(color: "green")
            datePickerTF.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            datePickerTF.textColor = #colorLiteral(red: 0.1921568627, green: 0.2784313725, blue: 0.2274509804, alpha: 1)
        case "yesterday":
            todayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            todayButton.configuration?.titleTextAttributesTransformer = changeColor(color: "green")
            yesterdayButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            yesterdayButton.configuration?.titleTextAttributesTransformer = changeColor(color: "white")
            datePickerTF.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            datePickerTF.textColor = #colorLiteral(red: 0.1921568627, green: 0.2784313725, blue: 0.2274509804, alpha: 1)
        case "otherDay":
            todayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            todayButton.configuration?.titleTextAttributesTransformer = changeColor(color: "green")
            yesterdayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            yesterdayButton.configuration?.titleTextAttributesTransformer = changeColor(color: "green")
            datePickerTF.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            datePickerTF.textColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
        default:
            return
        }
    }
    
    private func changeColor(color: String) -> UIConfigurationTextAttributesTransformer {
        if color == "white" {
            return  UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.foregroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                return outgoing }
        } else {
            return  UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.foregroundColor = #colorLiteral(red: 0.1921568627, green: 0.2784313725, blue: 0.2274509804, alpha: 1)
                return outgoing }
        }
        
    }
    
    private func changeSegmentedTextColor(selected: UISegmentedControl) {
        selected.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
    }
}

//MARK: - Work with delegation
extension AddTransactionViewController: CalculatorViewControllerDelegate, CategoriesVCDelegate {
    func getCategory(category: Category) {
        selectedCategory = category
        categoryButton.setTitle(selectedCategory?.name, for: .normal)
        categoryButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            outgoing.foregroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            return outgoing
        }
        categoryButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    
    func fillValueTF(value: String) {
        valueTextField.text = value
    }
    
}

//MARK: - Work with PickerView
extension AddTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return wallets.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let wallet = wallets[row]
        selectedWallet = wallet
        
        return selectedWallet?.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let wallet = wallets[row]
        selectedWallet = wallet
        walletTextField.text = selectedWallet?.name
        walletTextField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        walletTextField.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        walletTextField.resignFirstResponder()
    }
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}


//MARK: - Work with TextField
extension AddTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
//MARK: - Work with Alert
extension AddTransactionViewController {
    private func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
