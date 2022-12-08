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
    
    //MARK: - Private Properties
    //???? перенести
    var selectedType = "income"
    private var wallets: Results<Wallet>!
    private var selectedDate: String = ""
    private var selectedDay = ""
    private let datePicker = UIDatePicker()
  var test = "1"
    
    //MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        wallets = StorageManager.shared.realm.objects(Wallet.self)
        createDatePicker()
    }
    
    //MARK: - IBActions

    @IBAction func segmentedControllPressed() {
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0: selectedType = "income"
        default: selectedType = "expence"
        }
    }
    
    @IBAction func todayPressed() {
        selectedDay = "today"
        selectedDate = getDate()
        changeColor()
    }
    
    @IBAction func yesterdayPressed() {
        selectedDay = "yesterday"
        selectedDate = getDate()
        changeColor()
    }
    
    
    @IBAction func saveButtonPressed() {
        saveTransaction()
    }
    
    @IBAction func cancelButtonPressed() {
    }
    
}


extension AddTransactionViewController {
    
    
    //MARK: - Private Methods
    private func saveTransaction() {
        guard let wallet = wallets.first else { return }
        guard let transaction = makeTransaction() else { return }
        
        DispatchQueue.main.async {
            StorageManager.shared.addTransaction(wallet: wallet, transaction: transaction)
            print("ok")
        }
    }
    
    private func makeTransaction() -> Transaction? {
        
        let transaction = Transaction()
        
        let value = Double(valueTextField.text ?? "0") ?? 0
        
        transaction.value = value
        transaction.type = selectedType
        
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
    
    private func createDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
                
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        datePickerTF.inputAccessoryView = toolbar
        datePickerTF.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
    }

    @objc private func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "dd/MM/yy"
        
        datePickerTF.text = formatter.string(from: datePicker.date)
        selectedDate = datePickerTF.text ?? "0"
        selectedDay = "otherDay"
        changeColor()
        self.view.endEditing(true)
    }
    
    func changeColor() {

        switch selectedDay {
        case "today":
            todayButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            yesterdayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            datePickerTF.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
        case "yesterday":
            todayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            yesterdayButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            datePickerTF.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
        case "otherDay":
            todayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            yesterdayButton.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            datePickerTF.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        default:
            return
    
        }
    }
}


extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
