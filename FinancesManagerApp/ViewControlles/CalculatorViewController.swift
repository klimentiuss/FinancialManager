//
//  NewCalculatorViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 21.12.2022.
//

import UIKit

protocol CalculatorViewControllerDelegate {
    func fillValueTF(value: String)
}

class CalculatorViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var displayResultLabel: UILabel!
    
    //MARK: - Private Properties
    var delegate: CalculatorViewControllerDelegate?
    
    private var stillTyping = false
    private var dotIsPlaced = false
    private var firstOperand: Double = 0
    private var secondOperand: Double = 0
    private var operationSing: String = ""
    private var currentInput: Double {
        get {
            return Double(displayResultLabel.text ?? "0") ?? 0
        }
        set {
            let value = "\(newValue)"
            let valueArray = value.components(separatedBy: ".")
            if valueArray[1] == "0" {
                displayResultLabel.text = "\(valueArray[0])"
            } else {
                displayResultLabel.text = "\(newValue)"
            }
            stillTyping = false
        }
    }
    
    //MARK: - LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    //MARK: - Private Methods
    private func operateWithTwoOperands(operation: (Double, Double) -> Double) {
        currentInput = operation(firstOperand, secondOperand)
        stillTyping = false
    }
    
    //MARK: - IBActions
    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let value = displayResultLabel.text else { return }
        delegate?.fillValueTF(value: value)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        let number = sender.currentTitle
        guard let displayText = displayResultLabel.text else { return }
        
        if stillTyping {
            if displayText.count < 20 {
                displayResultLabel.text = displayText + (number ?? "404")
            }
        } else {
            displayResultLabel.text = number
            stillTyping = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func twoOperandsSignPressed(_ sender: UIButton) {
        operationSing = sender.currentTitle ?? "404"
        firstOperand = currentInput
        stillTyping = false
        dotIsPlaced = false
    }
    
    
    @IBAction func equalitySignPressed(_ sender: UIButton) {
        if stillTyping {
            secondOperand = currentInput
        }
        
        dotIsPlaced = false
        
        switch operationSing {
        case "+":
            operateWithTwoOperands(operation: {$0 + $1})
        case "-":
            operateWithTwoOperands(operation: {$0 - $1})
        case "x":
            operateWithTwoOperands(operation: {$0 * $1})
        case "/":
            operateWithTwoOperands(operation: {$0 / $1})
        default: break
        }
    }
    
    @IBAction func allClearPressed(_ sender: UIButton) {
        firstOperand = 0
        secondOperand = 0
        currentInput = 0
        displayResultLabel.text = "0"
        stillTyping = false
        dotIsPlaced = false
        operationSing = ""
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @IBAction func percentPressed(_ sender: UIButton) {
        if firstOperand == 0 {
            currentInput = currentInput / 100
        } else {
            secondOperand = firstOperand * currentInput / 100
        }
    }
    
    @IBAction func decimalPressed(_ sender: UIButton) {
        if stillTyping && !dotIsPlaced {
            displayResultLabel.text = displayResultLabel.text! + "."
            dotIsPlaced = true
        } else if !stillTyping && !dotIsPlaced {
            displayResultLabel.text = "0."
            stillTyping = true
            dotIsPlaced = true
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        displayResultLabel.text?.removeLast()
    }
    
}
