//
//  Item.swift
//  Todoey
//
//  Created by TechWithTyler on 10/11/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {

	@objc dynamic var title: String = String()

	@objc dynamic var done: Bool = false

	@objc dynamic var dateCreated: Date? = nil

	var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
	
}
