//
//  PaymentQueueProtocol.swift
//  InspoQuotes
//
//  Created by Santos, Rafael Costa on 31/01/2023.
//  Copyright © 2023 London App Brewery. All rights reserved.
//

import Foundation

public protocol PaymentQueueProtocol {
    func resultFromPaymentQueueWithSuccess()
    func resultFromPaymentQueueWithError(error: String)
}
