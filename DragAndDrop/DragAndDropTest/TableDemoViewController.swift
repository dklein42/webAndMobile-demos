//
//  DragDropTestTableViewController.swift
//  DragAndDropTest
//
//  Created by Daniel Klein on 16.07.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit
import MobileCoreServices

class TableDemoViewController: UITableViewController, UITableViewDragDelegate, UITableViewDropDelegate {
    var products = [
        Product(name: "T-Shirt", category: "Shirts", price: 19.99),
        Product(name: "Log Boots", category: "Shoes", price: 49.99),
        Product(name: "Lolly", category: "Sweets", price: 0.99),
        Product(name: "Sweatshirt", category: "Shirts", price: 29.99),
        Product(name: "w&m", category: "Magazines", price: 14.95),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.allowsMultipleSelection = true
        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Subtitle", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = "\(product.name) for \(product.price)"
        cell.detailTextLabel?.text = product.category
        return cell
    }

    // MARK: Drag Support
    private func dragItem(for indexPath: IndexPath) -> UIDragItem {
        let product = products[indexPath.row]
        let itemProvider = NSItemProvider(object: product)
        
//        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
//            completion(nameData, nil)
//            return nil
//        }
        
        return UIDragItem(itemProvider: itemProvider)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [dragItem(for: indexPath)]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return [dragItem(for: indexPath)]
    }

    // MARK: Drop Support
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        let operation: UIDropOperation
        
        if tableView.hasActiveDrag {
            operation = session.items.count > 1 ? .cancel : .move
        }
        else {
            operation = .copy
        }
        
        return UITableViewDropProposal(operation: operation, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
        
        coordinator.session.loadObjects(ofClass: Product.self) { items in
            let products = items as! [Product]
            var finalDestinationIndexPaths = [IndexPath]()
            
            for (index, item) in products.enumerated() {
                let finalDestination = IndexPath(row: destinationIndexPath.row+index, section: 0)
                self.products.insert(item, at: finalDestination.row)
                finalDestinationIndexPaths.append(finalDestination)
            }

            tableView.beginUpdates()
            
            if coordinator.proposal.operation == .move {
                let itemsToMove: [IndexPath] = coordinator.items.flatMap({ item in
                    item.sourceIndexPath
                })

                for (index, sourceIndexPath) in itemsToMove.enumerated() {
                    self.products.remove(at: sourceIndexPath.row)
                    
                    let adjustedFinalDestination = finalDestinationIndexPaths[index].row >= self.products.count ? self.products.count-itemsToMove.count : finalDestinationIndexPaths[index].row
                    
                    tableView.moveRow(at: sourceIndexPath, to: IndexPath(row: adjustedFinalDestination, section: 0))
                }
            }
            else {
                tableView.insertRows(at: finalDestinationIndexPaths, with: .automatic)
            }
            
            tableView.endUpdates()
        }
    }
}
