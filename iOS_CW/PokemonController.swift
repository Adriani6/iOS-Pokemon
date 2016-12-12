//
//  PokemonController.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 09/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//

import Foundation
import UIKit

class PokemonController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pokemonSpeedLbl: UITextField!
    @IBOutlet weak var pokemonDefenceSpeedLbl: UITextField!
    @IBOutlet weak var pokemonDefenceLbl: UITextField!
    @IBOutlet weak var pokemonAttSpeedLbl: UITextField!
    @IBOutlet weak var pokemonAttackLbl: UITextField!
    @IBOutlet weak var pokemonMaxHPLbl: UITextField!
    @IBOutlet weak var pokemonHPLbl: UITextField!
    @IBOutlet weak var newPokemonImage: UIImageView!
    @IBOutlet weak var newPokemonName: UILabel!
    @IBOutlet weak var pokemonType: UIPickerView!
    
    // Pokemon Types for Picker
    let pickerDataSource = ["Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"];
    // Selected Pokemon
    var pokemonToModify:String!
    // Attributes of Selected Pokemon
    var pokemonInSpotLightAttrs:NSDictionary!
    // Custom Delegate to communicate back and forth with another segue.
    var delegate:PokemonControllerDelegate? = nil
    
    // Function to register a new Pokemon to Pokedex
    @IBAction func registerNewPokemon(sender: AnyObject) {
        
        //Release Time. I set this variable here on purpose as I have a lot of other attributes already making the view cluttered.
        let expiry = 120
        
        // New Mutable Dictionary
        let newPokemon = NSMutableDictionary()
        
        // Catching any inappropriate values entered when new Pokemon attempted to be added. Responses are also generated here for the user and return statement ensures the code isn't getting executed.
        if Int(pokemonHPLbl.text!) == nil{self.showMessage("Invalid Value", message: "HP (as number) is required."); return}
        
        if Int(pokemonMaxHPLbl.text!) == nil{self.showMessage("Invalid Value", message: "Max. HP (as number) is required."); return}
        
        if Int(pokemonAttackLbl.text!) == nil{self.showMessage("Invalid Value", message: "Attack (as number) is required."); return}
        
        if Int(pokemonAttSpeedLbl.text!) == nil{self.showMessage("Invalid Value", message: "Attack Speed (as number) is required."); return}
        
        if Int(pokemonDefenceLbl.text!) == nil{self.showMessage("Invalid Value", message: "Defence (as number) is required."); return}
        
        if Int(pokemonDefenceSpeedLbl.text!) == nil{self.showMessage("Invalid Value", message: "Defence Speed (as number) is required."); return}
        
        if Int(pokemonSpeedLbl.text!) == nil{self.showMessage("Invalid Value", message: "Speed (as number) is required."); return}

        // Setting Values for the specific pokemon inside the previously created Muable Dictionary
        newPokemon.setValue(Int(pokemonHPLbl.text!), forKey: "HP")
        newPokemon.setValue(Int(pokemonMaxHPLbl.text!), forKey: "MaxHP")
        newPokemon.setValue(Int(pokemonAttackLbl.text!), forKey: "Attack")
        newPokemon.setValue(Int(pokemonAttSpeedLbl.text!), forKey: "Attack Speed")
        newPokemon.setValue(Int(pokemonDefenceLbl.text!), forKey: "Defence")
        newPokemon.setValue(Int(pokemonDefenceSpeedLbl.text!), forKey: "Defence Speed")
        newPokemon.setValue(Int(pokemonSpeedLbl.text!), forKey: "Speed")
        newPokemon.setValue(self.pickerDataSource[pokemonType.selectedRowInComponent(0)], forKey: "Type")
        newPokemon.setValue(Int(expiry), forKey: "Expiry")
        
        // Creating a new StorageHandler object.
        let sh = StorageHandler()
        
        // Capturing a returned Boolean which determines if the pokemon was successfully added to our persistant storage list.
        let wasAdded = sh.addPokemon(pokemonToModify, data: newPokemon)
            
        // Check if was caught then perform an action accordingly
        if wasAdded{
            //Show Alert message to the user
            self.showMessage("New Pokemon", message: "\(pokemonToModify) was successfully caught!")
        }
        else
        {
            //Show Alert message to the user
            self.showMessage("New Pokemon Failue", message: "\(pokemonToModify) was not caught!")
        }
        
        //Check if delegate was initialized
        if (delegate != nil) {
            //Run the delegates function.
            delegate!.myVCDidFinish(self)
        }
    }

    // Function which initializes screen components for the user.
    func initialize()
    {
        // Place pokemon name inside the label.
        newPokemonName.text = pokemonToModify

        // Create a new NSURL object, with URL to the image of the pokemon.
        let imageURL = NSURL(string: "https://img.pokemondb.net/artwork/"+pokemonToModify.lowercaseString+".jpg")
        
        //Check if the imageURL wasn't an error or is somehow empty.
        if(imageURL != nil){
            // Try to get the image
            if let imagedData = NSData(contentsOfURL: imageURL!)
            {
                // Image was successfully taken from the website.
                self.newPokemonImage.image = UIImage(data: imagedData)
            }
            else
            {
                // Either no image found or error downloading, so it's substituted with another one of a pokeball.
                self.newPokemonImage.image = UIImage(named: "pokeball")
            }
            
        }
    }
    
    //Overriding default segue initialization 
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    //Overriding default segue initialization 
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
        self.pokemonType.dataSource = self;
        self.pokemonType.delegate = self;
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "s4o29g.png")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Creating one section within the pickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Returning the number of rows (items) for the pickerView
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    // Returning correct values from array for given index within the pickerView
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    // Creating a function to show Alerts (Messages) to the user
    func showMessage(title: String, message: String)
    {
        
        //Creating a controller for the alert box
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)

        //Set options for the alert box
        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        
        //Ading options to the alert Controller.
        alertController.addAction(defaultAction)

        //Presenting the alert to the user by adding it to current view.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// Protocol for communication between controllers
protocol PokemonControllerDelegate{
    func myVCDidFinish(controller:PokemonController)
}