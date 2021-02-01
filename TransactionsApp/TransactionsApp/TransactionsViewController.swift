//
//  TransactionsViewController.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var stateController: TransactionsStateController!
    
    var refreshController: TransactionsRefreshController? 
    var tableModel = [TransactionCellController]()
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        configureStateController()
        setRemoveButtonState(isEditing: stateController.isEditing)
        refreshController?.refresh()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(for: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if stateController.isEditing {
            tableView.unhighlightCell(at: indexPath)
        }
        setRemoveButtonState(isEditing: stateController.isEditing)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if stateController.isEditing {
            tableView.highlightCell(at: indexPath)
        }
        setRemoveButtonState(isEditing: stateController.isEditing)
    }
    
    // MARK: - Actions
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        removeSelectedRows()
        removeButton.isHidden = true
    }
    
    // MARK: - Private
    
    private func configureStateController() {
        stateController.onEditingStateChange = { [weak self] (isEditing) in
            guard let self = self else { return }
            
            // Enable/disable selection
            if isEditing {
                self.tableView.allowsSelection = true
                self.tableView.allowsMultipleSelection = true
                
            } else {
                self.tableView.allowsSelection = false
                self.tableView.allowsMultipleSelection = false
                
                self.tableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
                    self.tableView.unhighlightCell(at: indexPath)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                })
            }
            self.setRemoveButtonState(isEditing: isEditing)
        }
    }
    
    private func removeSelectedRows() {
        guard let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows else {
            return
        }
        
        removeTableModels(at: indexPathsForSelectedRows)
        tableView.deleteRows(at: indexPathsForSelectedRows, with: .fade)
    }
    
    private func removeTableModels(at indexes: [IndexPath]) {
        let rows = indexes.map { $0.row }.sorted(by: { (a, b) -> Bool in
            a > b
        })
        
        rows.forEach({ (row) in
            tableModel.remove(at: row)
        })
    }
    
    private func setRemoveButtonState(isEditing: Bool) {
        if !isEditing || tableView.indexPathsForSelectedRows?.isEmpty ?? true {
            removeButton.isHidden = true
        } else {
            removeButton.isHidden = false
        }
    }
}

private extension UITableView {
    func unhighlightCell(at indexPath: IndexPath) {
        let cell = self.cellForRow(at: indexPath) as? TransactionTableViewCell
        cell?.highlightView.isHidden = false
    }
    
    func highlightCell(at indexPath: IndexPath) {
        let cell = self.cellForRow(at: indexPath) as? TransactionTableViewCell
        cell?.highlightView.isHidden = true
    }
}

