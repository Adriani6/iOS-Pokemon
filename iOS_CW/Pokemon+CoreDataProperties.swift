//
//  Pokemon+CoreDataProperties.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 07/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pokemon {

    @NSManaged var name: String?
    @NSManaged var weight: NSNumber?
    @NSManaged var species: String?
    @NSManaged var attack: NSNumber?
    @NSManaged var defense: NSNumber?
    @NSManaged var img: String?
    @NSManaged var speed: NSNumber?
    @NSManaged var ability: String?

}
