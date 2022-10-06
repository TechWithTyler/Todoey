//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

	var itemArray: [Item] = []

	var selectedCategory: Category? = nil {
		didSet {
			loadData()
		}
	}

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	// MARK: - UITableView Delegate and Data Source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemArray.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
		let item = itemArray[indexPath.row]
		var contentConfiguration = UIListContentConfiguration.cell()
		contentConfiguration.text = item.title
		cell.contentConfiguration = contentConfiguration
		cell.accessoryType = (item.done) ? .checkmark : .none
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
                //       Keeping this in case deletion is implemented later
		//		context.delete(itemArray[row])
		//		itemArray.remove(at: row)
		itemArray[row].done.toggle()
		saveData()
		tableView.reloadData()
		tableView.deselectRow(at: indexPath, animated: true)
	}

	// MARK: - Add New Items

	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
		var textField = UITextField()
		let action = UIAlertAction(title: "Add", style: .default) {
			(action) in
			let newItem = Item(context: self.context)
			newItem.title = textField.text!
			newItem.done = false
			newItem.parentCategory = self.selectedCategory
			self.itemArray.append(newItem)
			self.saveData()
			self.tableView.reloadData()
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

	func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
		let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
		if let additionalPredicate = predicate {
			let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [additionalPredicate, categoryPredicate])
			request.predicate = compoundPredicate
		} else {
			request.predicate = categoryPredicate
		}
		do {
			let result = try context.fetch(request)
			itemArray = result
		} catch {
			print("Error fetching data from context: \(error)")
		}
		tableView.reloadData()
	}

	func saveData() {
		do {
			try context.save()
		} catch {
			print("Error saving context: \(error)")
		}
	}

}

// MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		let formatString = "title CONTAINS[cd] %@"
		let predicate = NSPredicate(format: formatString, searchBar.text!)
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		request.predicate = predicate
		request.sortDescriptors = [sortDescriptor]
		loadData(with: request, predicate: predicate)
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

