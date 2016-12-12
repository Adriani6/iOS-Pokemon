//
//  FileHandler.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 07/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//

import Foundation
// Import CoreData for pList
import CoreData
import UIKit

public class StorageHandler {
    
    // Create a new Mutable Dictionary
    var dict = NSMutableDictionary()
    
    // Function which adds a pokemon to the pList and return boolean if successful or not
    func addPokemon(name: String, data: NSMutableDictionary) -> Bool
    {
        // Check that the pokemon is not in list already
        if (dict.objectForKey(name) != nil)
        {
            //Pokemon not added
            return false
        }
        else
        {
            // Load the list
            self.loadFiles()
            // Add new pokemon
            dict.setObject(data, forKey: name)
            //Save the list
            self.saveData()
            
            //Let the calling function know that pokemon was added
            return true;
        }
        
    }
    
    // Function which checks if pokemon exists already within the pList returns Boolean accordingly
    func doesExist(pokemon: String) -> Bool
    {
        //Check if its empty
        if (dict.objectForKey(pokemon) != nil)
        {
            //Taken
            return true
        }
        else
        {
            //Empty
            return false
        }
    }
    
    // Gets number of pokemons in list
    func getPokedexCount() -> Int
    {
        // Return the count
        return dict.count
    }
    
    // This function retrieves pokemon from the loaded array of pokemons and returns the name (which is also the key)
    func getPokemonFromIndex(index : Int) -> String
    {
        // Return the pokemon 
        return String(dict.allKeys[index])
        // Not to self, this should be wrapped incase the index passed is out of boundries.
    }
    
    // Get pokemon attributes, accepts pokemon name and returns dictionary of attributes
    func getPokemonAttributes(p: String) -> NSDictionary {
        // Get the attributes as Dictionary
        let pokemon:NSDictionary = dict.objectForKey(p) as! NSDictionary
        
        //return pokemon attributes
        return pokemon  
    }
    
    // Function which returns the Speed Attribute for given pokemon
    func getSpeed (pokemon: NSDictionary) -> String
    {
        // Get the "Speed" key
        let speed = String(pokemon.valueForKey("Speed")!)
        // Return speed
        return speed
    }
    
    // Get the pokemon Type
    func getType (pokemon: NSDictionary) -> String
    {
        // Get the "Type" Key from dict
        let type = String(pokemon.valueForKey("Type")!)
        // Return type
        return type
    }
    
    // Function which checks if a pokemon expired and returns a boolean accordingly
    func hasExpired() -> Bool
    {
        var expired:Bool = false

        // Counter for iterations
        var i = 0
        //while the counter is less that the array size
        while(i < dict.count)
        {
            //Get the pokemon
            let key = getPokemonFromIndex(i)
            //Get pokemon attributes
            let attr = self.getPokemonAttributes(key)
            
            //Get the release time attribute and check if its not null
            if attr.valueForKey("Expiry") != nil
            {
                // Parse the release time as integer and remove one from it
                let newExpiry = Int(attr.valueForKey("Expiry") as! NSNumber) - 1
                
                // If release time more than 0
                if newExpiry > 0
                {
                    // Update the new expiry persistantly
                    attr.setValue(newExpiry, forKey: "Expiry")
                    dict.setValue(attr, forKey: key)
                    //Save the modified data
                    self.saveData()
                }
                else
                {
                    // Pokemons  release time is up

                    //Remove the pokemon from collection
                    self.removeItem(key)
                    //Save the collection
                    self.saveData()
                    //Reload the collection
                    self.loadFiles()
                    //Mark that a pokemon was expired
                    expired = true;
                    //Decrement the iterations to avoid out on boundries exception
                    i -= 1
                }
            }
            // Increment the i variable
            i += 1
        }

        // Return the variable to let the caller know that there was at least 1 pokemon which expired
        return expired
    }

    // Function to load file with pokemon collection
    func loadFiles()
    {
        // Getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        // Setting NSURL from the above path search
        let documentsDirectory = NSURL(fileURLWithPath: paths[0] as! String)
        //Getting the path to the file which contains the pokemon list
        let path = documentsDirectory.URLByAppendingPathComponent("PokemonFile.plist")

        // FileManger to allow modification of files on the device
        let fileManager = NSFileManager.defaultManager()
    
        //check if file exists
        if(!fileManager.fileExistsAtPath(path.path!))
        {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("PokemonFile", ofType: "plist")
            {
                // Try catch block
                do
                {
                    //Copy the default pokemon table from the boundle to user device
                    try fileManager.copyItemAtPath(bundlePath, toPath: path.path!)
                    print("Created a Copy of the File.")
                    
                }
                catch
                {
                    //Error when copying the files over
                    print("Exception Copying Game Data!")
                }
            }
            else
            {
                // This should not happen, but as debug...
                print("Game Data File is not inside the project.")
            }
        }
        else
        {
            // No need to copy over the data. It's already oon the device
            print("Game Data already exits!")
        }
        
        //Set the local variable with dictionary of pokemons that was loaded by the function
        dict = NSMutableDictionary(contentsOfFile: path.path!)!
        
    }

    // This is a debug functio which removes the game data from the device. Made for testing purposes.    
    func removeGameData()
    {
        // Getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        // Setting NSURL from the above path search
        let documentsDirectory = NSURL(fileURLWithPath: paths[0] as! String)
        //Getting the path to the file which contains the pokemon list
        let path = documentsDirectory.URLByAppendingPathComponent("PokemonFile.plist")
        
        // FileManger to allow modification of files on the device
        let fileManager = NSFileManager.defaultManager()
        
        //Try catch
        do
        {
            //Remove files from specified path
            try fileManager.removeItemAtURL(path)
            print("Removed")
        }
        catch
        {
            print("Error")
        }
        
    }
    
    // Function to save game files, at the point when this function is called, Game data is already on user device
    func saveData()
    {
        // Getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        // Setting NSURL from the above path search
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        //Getting the path to the file which contains the pokemon list
        let path = documentsDirectory.stringByAppendingPathComponent("PokemonFile.plist")
        
        
        //writing to GameData.plist
        dict.writeToFile(path, atomically: false)
    }
    
    //Function which removes pokemons from the collection forever.
    func removeItem(pokemonToRemove : String)
    {
        // Getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        // Setting NSURL from the above path search
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        //Getting the path to the file which contains the pokemon list
        let path = documentsDirectory.stringByAppendingPathComponent("PokemonFile.plist")
        
        //Remove an Object by a key lookup
        dict.removeObjectForKey(pokemonToRemove);
        //Save the file again.
        dict.writeToFile(path, atomically: false)
    }
    
}
