//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: SwipeTableViewController {

	var itemArray: Results<Item>?

	let realm = try! Realm()

	var selectedCategory: Category? = nil {
		didSet {
			loadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	// MARK: - UITableView Delegate and Data Source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemArray?.count ?? 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		if let item = itemArray?[indexPath.row] {
			var contentConfiguration = UIListContentConfiguration.cell()
			contentConfiguration.text = item.title
			cell.contentConfiguration = contentConfiguration
			cell.accessoryType = (item.done) ? .checkmark : .none
		} else {
			var contentConfiguration = UIListContentConfiguration.cell()
			contentConfiguration.text = "No items!"
			cell.contentConfiguration = contentConfiguration
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		if let item = itemArray?[row] {
			do {
				try realm.write {
					item.done.toggle()
				}
			} catch {
				print("Error updating done status: \(error)")
			}
		}
		tableView.reloadData()
		tableView.deselectRow(at: indexPath, animated: true)
	}

	// MARK: - Add New Items

	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
		var textField = UITextField()
		let action = UIAlertAction(title: "Add", style: .default) {
			(action) in
			if let currentCategory = self.selectedCategory {
				do {
					try self.realm.write {
						let newItem = Item()
						newItem.title = textField.text!
						newItem.dateCreated = Date()
						currentCategory.items.append(newItem)
					}
				} catch {
					print("Error saving item: \(error)")
				}
				self.tableView.reloadData()
			}
		}
		alert.addTextField {
			(alertTextField) in
			alertTextField.placeholder = "Create new item"
			textField = alertTextField
		}
		alert.addAction(action)
		present(alert, animated: true)

	}

	// MARK: - Data Model Manipulation Methods

	func loadData() {
		itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
		tableView.reloadData()
	}

	// MARK: - Delete Data From Swipe

	override func updateModel(at indexPath: IndexPath) {
		if let itemForDeletion = itemArray?[indexPath.row] {
			do {
				try realm.write {
					realm.delete(itemForDeletion)
				}
			} catch {
				print("Error saving data: \(error)")
			}
		}
	}

}

// MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!)
			.sorted(byKeyPath: "dateCreated", ascending: true)
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if (searchBar.text?.isEmpty)! {
			loadData()
			DispatchQueue.main.async {
				searchBar.resignFirstResponder()
			}
		}
	}
	

}

