//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListController: SwipeTableViewController {
    
    var items: Results<TodoItem>?
    
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
            if let title = textField.text,
               let category = self.selectedCategory {
                do {
                    try Realm().write({
                        let newItem = TodoItem(value: ["title": title, "createdAt": Date()])
                        category.items.append(newItem)
                    })
                } catch let e {
                    print(e)
                }
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
        tableView.rowHeight = 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.item] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath),
           let item = items?[indexPath.item] {
            do {
                try Realm().write({
                    item.done = !item.done
                })
                cell.accessoryType = item.done ? .checkmark : .none
            } catch {
                print(error)
            }
        } else {
            print("No item")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveItem(_ todoItem: TodoItem) {
        do {
            try Realm().write({
                try Realm().add(todoItem)
            })
        } catch let e {
            print(e)
        }
    }
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        super.deleteItem(at: indexPath)
        if let itemToDelete = items?[indexPath.row] {
            do {
                try Realm().write({
                    try Realm().delete(itemToDelete)
                })
            } catch {
                print(error)
            }
        }
    }
}

extension TodoListController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?
            .filter("title CONTAINS[cd] %@", searchBar.text ?? "")
            .sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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

