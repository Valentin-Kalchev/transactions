//
//  TransactionsStateController.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit

@objc class TransactionsStateController: NSObject {
    @IBOutlet var editButton: UIButton!
    
    private(set) var isEditing: Bool = false
    var onEditingStateChange: ((Bool) -> Void)?
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        isEditing = !isEditing
        editButton.setTitle(isEditing ? "Done" : "Edit", for: .normal)
        onEditingStateChange?(isEditing)
    }
}
