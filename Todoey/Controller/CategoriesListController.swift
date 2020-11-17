//
//  CategoriesListController.swift
//  Todoey
//
//  Created by Noemi on 17/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoriesListController: UITableViewController {

    var categories: [TodoCategory] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            textField = tf
        }
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let title = textField.text {
                let newItem = TodoCategory(context: self.context)
                newItem.title = title
                self.categories.append(newItem)
                self.saveItems()
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
        let request: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch let e {
            print(e)
        }
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch let e {
            print(e)
        }
    }
}

extension CategoriesListController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        cell?.textLabel?.text = categories[indexPath.row].title
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
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
