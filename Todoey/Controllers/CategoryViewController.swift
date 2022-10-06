//
//  CategoryViewController.swift
//  Todoey
//
//  Created by TechWithTyler on 10/5/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

	var categoryArray: [Category] = []

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		loadData()
	}

	// MARK: - UITableView Delegate and Data Source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categoryArray.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
		let category = categoryArray[indexPath.row]
		var contentConfiguration = UIListContentConfiguration.cell()
		contentConfiguration.text = category.name
		cell.contentConfiguration = contentConfiguration
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let segueIdentifier = "goToItems"
		performSegue(withIdentifier: segueIdentifier, sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? ToDoListViewController, let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCategory = categoryArray[indexPath.row]
		}

	}

	// MARK: - Add New Categories

	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
		var textField = UITextField()
		let action = UIAlertAction(title: "Add", style: .default) {
			(action) in
			let newCategory = Category(context: self.context)
			newCategory.name = textField.text!
			self.categoryArray.append(newCategory)
			self.saveData()
			self.tableView.reloadData()
		}
		alert.addTextField {
			(alertTextField) in
			alertTextField.placeholder = "Create new category"
			textField = alertTextField
		}
		alert.addAction(action)
		present(alert, animated: true)

	}

	// MARK: - Data Model Manipulation Methods

	func loadData() {
		let request: NSFetchRequest<Category> = Category.fetchRequest()
		do {
			let result = try context.fetch(request)
			categoryArray = result
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
