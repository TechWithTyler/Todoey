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

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Items.plist", directoryHint: .notDirectory)

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		loadData()
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
		itemArray[indexPath.row].done.toggle()
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

	func loadData() {
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		do {
			let result = try context.fetch(request)
			itemArray = result
		} catch {
			print("Error fetching data from context: \(error)")
		}
	}

	func saveData() {
		do {
			try context.save()
		} catch {
			print("Error saving context: \(error)")
		}
	}

}

