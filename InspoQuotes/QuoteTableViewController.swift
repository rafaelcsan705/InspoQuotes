//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    var storeObserver = StoreObserver.shared
    @IBOutlet weak var restoreBtn: UIBarButtonItem!
    let productID = "com.londonappbrewery.InspoQuotes.PremiumQuotes"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeObserver.delegate = self
        checkUserPremiumStatus()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPurchased() {
            return quotesToShow.count
        } else {
            return quotesToShow.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        } else {
            cell.textLabel?.text = "Get More Quotes..."
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - Function
extension QuoteTableViewController {
    func checkUserPremiumStatus() {
        if isPurchased() {
            showPremiumQuotes()
        }
    }
    
    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User can't make payments.")
        }
    }
    
    func showPremiumQuotes() {
        if let premiumQuote = premiumQuotes.randomElement() {
            if !quotesToShow.contains(premiumQuote) {
                quotesToShow.append(contentsOf: premiumQuotes)
            }
        }
        
        tableView.reloadData()
    }
    
    func isPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        
        if purchaseStatus {
            print("Previously purchased")
        } else {
            print("Never purchased")
        }
        return purchaseStatus
    }
    
    func showAlert(title: String, description: String, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: style)
        alert.addAction(.init(title: "Confirm", style: .default) { action in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    func hideNavBarItem() {
        navigationItem.setRightBarButton(nil, animated: true)
    }
}


extension QuoteTableViewController: PaymentQueueProtocol {
    func resultFromPaymentQueueWithSuccess() {
        UserDefaults.standard.set(true, forKey: productID)
        showAlert(title: "Subscrição com sucesso.", description: "Agradecemos a subscrição e esperemos que desfrute.")
        hideNavBarItem()
        showPremiumQuotes()
    }
    
    func resultFromPaymentQueueWithError(error: String) {
        showAlert(title: "Subscrição sem sucesso.", description: "Lamentamos mas não foi possível concluir a subscrição. \n \(error)")
        hideNavBarItem()
    }
}

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    
    weak var delegate: PaymentQueueProtocol?
    static var shared = StoreObserver()
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // Payment Successfull
                delegate?.resultFromPaymentQueueWithSuccess()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                // Payment Failed
                if let error = transaction.error {
                    delegate?.resultFromPaymentQueueWithError(error: error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                // Transaction restored
                delegate?.resultFromPaymentQueueWithSuccess()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
