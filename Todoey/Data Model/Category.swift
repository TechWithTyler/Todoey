//
//  Category.swift
//  Todoey
//
//  Created by TechWithTyler on 10/11/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {

	@objc dynamic var name: String = String()

	let items = List<Item>()

}
