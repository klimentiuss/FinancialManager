//
//  TransactionViewController.swift
//  FinancesManagerApp
//
//  Created by Daniil Klimenko on 30.12.2022.
//

import UIKit

class TransactionViewController: UIViewController {

    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var fromToLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var transaction: Transaction?
    var delegate: MainViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    @IBAction func backPressed(_ sender: Any) {
    }
    
    private func configure() {
        transaction = delegate?.getTransaction()
        let transactionImage = transaction?.image
        if transactionImage == nil {
            imageView.isHidden = true
        } else {
            guard let imageData = transactionImage else { return }
            guard let image = UIImage(data: imageData) else { return }
            imageView.image = image
        }
            
        
        valueLabel.text = (transaction?.type ?? "") + String(Int(transaction?.value ?? 0))
        walletLabel.text = transaction?.wallet?.name
        categoryLabel.text = transaction?.category?.name
        dateLabel.text = transaction?.date
        noteTextView.text = transaction?.note
        
    
        if transaction?.type == "+" {
            fromToLabel.text = "To:"
        }
        
        if transaction?.date == "" {
            dateLabel.text = "Without date"
        }
        
        if transaction?.note == "" {
            noteTextView.text = "Without note"
        }
    }
}
