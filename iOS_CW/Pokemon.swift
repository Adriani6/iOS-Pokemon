//
//  Pokemon.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 07/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//

import Foundation
import CoreData

@objc(Pokemon)
public class Pokemon : NSManagedObject
{
    func getName() -> String{
        return name!
    }
    
    func getImageURL() -> String {
        return "https://img.pokemondb.net/artwork/charizard.jpg";
    }

}