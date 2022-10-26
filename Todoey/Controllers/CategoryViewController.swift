//
//  CategoryViewController.swift
//  Todoey
//
//  Created by TechWithTyler on 10/5/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {

	let realm = try! Realm()

	var categoryArray: Results<Category>?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		loadData()
	}

	// MARK: - UITableView Delegate and Data Source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categoryArray?.count ?? 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		let category = categoryArray?[indexPath.row]
		var contentConfiguration = UIListContentConfiguration.cell()
		contentConfiguration.text = category?.name ?? "No Categories!"
		cell.contentConfiguration = contentConfiguration
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let segueIdentifier = "goToItems"
		performSegue(withIdentifier: segueIdentifier, sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? ToDoListViewController, let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCategory = categoryArray?[indexPath.row]
		}

	}

	// MARK: - Add New Categories

	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
		var textField = UITextField()
		let action = UIAlertAction(title: "Add", style: .default) {
			(action) in
			let newCategory = Category()
			newCategory.name = textField.text!
			self.saveData(forCategory: newCategory)
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
		categoryArray = realm.objects(Category.self)
		tableView.reloadData()
	}

	func saveData(forCategory category: Category) {
		do {
			try realm.write({
				realm.add(category)
			})
		} catch {
			print("Error saving data: \(error)")
		}
	}

	// MARK: - Delete Data From Swipe

	override func updateModel(at indexPath: IndexPath) {
		if let categoryForDeletion = categoryArray?[indexPath.row] {
			do {
				try realm.write {
					realm.delete(categoryForDeletion)
				}
			} catch {
				print("Error saving data: \(error)")
			}
		}
	}

}
