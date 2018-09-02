//
//  CoffeeListViewController.swift
//  SiriShortcuts
//
//  Created by Daniel Klein on 22.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit

class CoffeeListViewController: UITableViewController {
    let coffeeMenu: [Coffee] = Coffee.allCases
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coffeeMenu.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coffee cell", for: indexPath)

        cell.textLabel?.text = self.coffeeMenu[indexPath.row].description

        return cell
    }
    
    @IBAction func deleteAllShortcutsButtonTapped(_ sender: Any) {
        ShortcutsManager.deleteAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CoffeeViewController {
            destinationVC.coffee = self.coffeeMenu[self.tableView.indexPathForSelectedRow!.row]
        }
    }
}
