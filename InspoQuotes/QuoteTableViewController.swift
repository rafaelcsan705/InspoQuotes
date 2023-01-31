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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesToShow.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
        } else {
            cell.textLabel?.text = "Get More Quotes..."
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: - Function
extension QuoteTableViewController {
    func getViewController() -> UIViewController? {
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topVC?.presentedViewController {
            topVC = presentedViewController
        }
        return topVC
    }
    
    func showAlert(title: String, description: String, style: UIAlertController.Style = .alert) {
        guard let vc = getViewController() else { return }
        let alert = UIAlertController(title: title, message: description, preferredStyle: style)
        alert.addAction(.init(title: "Confirm", style: .default) { action in
            vc.dismiss(animated: true)
        })
        vc.present(alert, animated: true)
    }
}


extension QuoteTableViewController: PaymentQueueProtocol {
    func resultFromPaymentQueueWithSuccess() {
        showAlert(title: "Subscrição com sucesso.", description: "Agradecemos a subscrição e esperemos que desfrute.")
    }
    
    func resultFromPaymentQueueWithError(error: String) {
        showAlert(title: "Subscrição sem sucesso.", description: "Lamentamos mas não foi possível concluir a subscrição. \n \(error)")
    }
}

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    
    let quotesTableView = QuoteTableViewController()
    static var shared = StoreObserver()
    
    override init() {
        super.init()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // Payment Successfull
                quotesTableView.resultFromPaymentQueueWithSuccess()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                // Payment Failed
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    quotesTableView.resultFromPaymentQueueWithError(error: errorDescription)
//                    print("Transaction failed due to error: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
