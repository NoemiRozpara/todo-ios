//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [TodoItem] = []
    
    var selectedCategory: TodoCategory? = nil {
        didSet {
            self.loadItems()
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            textField = tf
        }
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let title = textField.text {
                let newItem = TodoItem(context: self.context)
                newItem.title = title
                newItem.category = self.selectedCategory
                self.items.append(newItem)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell")
        let item = items[indexPath.item]
        cell?.textLabel?.text = item.title
        cell?.accessoryType = item.done ? .checkmark : .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let item = items[indexPath.item]
        item.done = !item.done
        saveItems()
        cell?.accessoryType = item.done ? .checkmark : .none
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch let e {
            print(e)
        }
    }
    
    func loadItems(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "category.title MATCHES[cd] %@", selectedCategory?.title ?? "")
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            try items = context.fetch(request)
        } catch let e {
            print(e)
        }
        tableView.reloadData()
    }
}

extension TodoListController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        if searchBar.text != nil {
            request.sortDescriptors = [NSSortDescriptor(key: "done", ascending: true)]
        }
        loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text ?? ""))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
