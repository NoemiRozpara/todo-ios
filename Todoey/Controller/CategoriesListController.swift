//
//  CategoriesListController.swift
//  Todoey
//
//  Created by Noemi on 17/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesListController: SwipeTableViewController {

    var categories: Results<TodoCategory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            textField = tf
        }
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let title = textField.text {
                let newItem = TodoCategory()
                newItem.title = title
                newItem.color = UIColor.randomFlat().hexValue()
                self.saveItem(newItem)
                self.tableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        alert.addAction(add)
        present(alert, animated: true, completion: nil)
    }
    
    func loadCategories() {
        do {
            try categories = Realm().objects(TodoCategory.self)
        } catch let e {
            print(e)
        }  
    }
    
    func saveItem(_ category: TodoCategory) {
        do {
            try Realm().write({
                try Realm().add(category)
            })
        } catch let e {
            print(e)
        }
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        super.deleteItem(at: indexPath)
        if let rowToDelete = self.categories?[indexPath.row] {
            do {
                try Realm().write({
                    try Realm().delete(rowToDelete)
                })
            } catch {
                print(error)
            }
        }
    }
}

extension CategoriesListController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        let newBgColor = UIColor(hexString: category.color)
        cell.textLabel?.textColor = ContrastColorOf(newBgColor ?? .white, returnFlat: true)
        cell.backgroundColor = newBgColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListController
        
        let selectedIndexPath = tableView.indexPathForSelectedRow
        let selectedCategory = categories[selectedIndexPath?.row ?? 0]
        
        destinationVC.selectedCategory = selectedCategory
    }
}
