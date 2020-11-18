//
//  Data.swift
//  Todoey
//
//  Created by Noemi on 18/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date?
    var category = LinkingObjects(fromType: TodoCategory.self, property: "items")
}
