//
//  TodoCategory.swift
//  Todoey
//
//  Created by Noemi on 18/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class TodoCategory: Object {
    @objc dynamic var title: String = ""
    let items: List<TodoItem> = List()
}
