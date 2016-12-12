//
//  PokemonListController.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 07/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//

import Foundation
import UIKit
// Importing AVF Library to play music
import AVFoundation

class PokemonListController : UITableViewController, PokemonControllerDelegate{
    
    //@IBOutlet weak var PokedexPreviewImage: UIImageView!
    @IBOutlet var pokedexTableView: UITableView!
    
    // Button Outlet To modify button text
    @IBOutlet weak var soundButton: UIButton!
    // Creating StorageHandler object
    let sh = StorageHandler();
    // Name of SelectedPokemon (Later this variable is passed to another segue)
    var selectedPokemon : String!
    // Name of pokemon which is being created
    var newPokemonName:String!
    //Timer object which counts down the time of release when user is in preview
    var timer = NSTimer()
    // Creating an audio player from the AVFoundation Library
    var player: AVAudioPlayer?

    //Button Click Event to mute/unmute music
    @IBAction func muteFunction(sender: AnyObject) {
        // Check what the current state of the button is (By default always on Mute at first)
        if soundButton.titleLabel!.text == "Mute" {
            //Stop playing music
            player?.stop()
            //Change button text
            soundButton.setTitle("Play", forState: .Normal)
        }
        else
        {
            //Start playing music
            player?.play()
            //Change button text
            soundButton.setTitle("Mute", forState: .Normal)
        }
        
    }

    // Overriding the viewDidLoad Event
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is a DEBUG purpose ONLY. This function removes Game Data form Client Device
        //sh.removeGameData()
        //Load Game Files
        sh.loadFiles()
        //Reload table to display the loaded data
        self.pokedexTableView.reloadData()
        // Call to function whcih will Iterate over pokemons to check if they expired
        self.checkIfPokemonExpired()
        
        //Try to create a sound object with music within the project boundle
        //Create NSURL object with path to the audio file
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("PokemonSong", ofType: "mp3")!)
        //Try to load the audio file to the player created previously
        do{
            // Loading attempt of audio
            player = try AVAudioPlayer(contentsOfURL:sound)
            // Set the number of loops to infinite (So the music plays forever)
            player?.numberOfLoops = -1
            // Load the audio file
            player!.prepareToPlay()
            // Play el musicue
            player!.play()
        }catch {
            // Catch the error
            print("Error getting the audio file")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function which is only called by the delegate from other class
    func myVCDidFinish(controller: PokemonController) {
        // Reload the files from the persistant storage
        sh.loadFiles()
        // Reload table data to accomodate for new entries
        pokedexTableView.reloadData()
        // Go back to appropriate view
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    // Overriding the default preparation to launch a segue to accomodate switching programatically.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //Check which Segue
        if (segue.identifier == "pokemonPreview") {
            // Create the view Controller
            let svc = segue.destinationViewController as! PokemonView;
            // Pass the selected pokemon to the Controller (Class)
            svc.pokemonInSpotlight = selectedPokemon
            // Get the pokemons Attributes
            svc.pokemonInSpotLightAttrs = sh.getPokemonAttributes(selectedPokemon)
        }
        
        if segue.identifier == "newPokemon"{
            // Check if pokemon name is not empty
            if newPokemonName != nil{
                // Create the view Controller
                let svc = segue.destinationViewController as! PokemonController;
                // Pass the new pokemon to the Controller (Class)
                svc.pokemonToModify = newPokemonName
                // Set its delegate to this class
                svc.delegate = self
            }
            else
            {
                // Show error to the user when name is empty
                showMessage("Pokedex Error", message: "Invalid Pokemon Name.")
            }
            
        }
    }
    
    // Return number of pokemons to populate the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sh.getPokedexCount()
    }

    // Loading of data into custom cells
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Select the custom UI cell
        let cell = tableView.dequeueReusableCellWithIdentifier("customcell") as UITableViewCell!
        // Get pokemon name in array from row index
        let pokemonName = sh.getPokemonFromIndex(indexPath.row)
        
        //Check if Pokemons expired (their release time is up)
        sh.hasExpired()
        
        // Create new NSURL object to download image of the pokemon
        let imageURL = NSURL(string: "https://img.pokemondb.net/artwork/"+pokemonName.lowercaseString+".jpg")
        
        // Get the image element by tag from the custom cell view
        let img = cell.viewWithTag(100) as! UIImageView
        
        // Check if the imageURL is not null somehow
        if(imageURL != nil){
            // Try to download the image
            if let imagedData = NSData(contentsOfURL: imageURL!)
            {
                // Image downloaded, set it to image element
                img.image = UIImage(data: imagedData)
                
            }
            else
            {
                // Image is not downloaded or error occured, substitute the image with a 'default' image of a pokeball
                img.image = UIImage(named: "pokeball")
            }
        }
        
        // Get the pokemon name label by tag from the custom cell element
        let pokemonNameLbl = cell.viewWithTag(101) as! UILabel
        // Get the pokemon type label by tag from the custom cell
        let pokemonTypeLbl = cell.viewWithTag(102) as! UILabel
        
        //Set the pokemon name to cells label
        pokemonNameLbl.text = pokemonName
        //Set pokemon type to the cell label
        pokemonTypeLbl.text = "\(sh.getType(sh.getPokemonAttributes(pokemonName)))"
        
        // Return the created cell
        return cell
    }
    
    //Overriding the cell behaviour when put into 'edit' mode.
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Create a new row action for the cell
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            //When the action button is clicked, given pokemon gets removed
            self.sh.removeItem(self.sh.getPokemonFromIndex(indexPath.row))
            //Reload data to accomodate for the removed pokemon
            self.pokedexTableView.reloadData()
        }
        //Set the action button background
        delete.backgroundColor = UIColor.redColor()
        
        //Return the action as an array as there can be multiple actions.
        return [delete]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    //Selecting A Cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the name of selected pokemon by getting the celected rows pokemon name label to extract data from
        let cell = tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(101) as! UILabel
        //Extracting data
        selectedPokemon = cell.text

        //Switch to Preview Screen
        self.performSegueWithIdentifier("pokemonPreview", sender: self)

    }
    
    // Button Event when user wants to add a new pokemon
    @IBAction func newPokemonButton(sender: AnyObject) {
        self.getPokemonName()
    }
    
    //Function which adds a message to the current view from this class.
    func showMessage(title: String, message: String)
    {
        // Define the controller and style for the alert box 
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        
        // Attach actions to controller
        alertController.addAction(defaultAction)
        // Show the controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Go through verification of the new pokemon
    func getPokemonName()
    {
        //Create a new alert message, this time with an inputbox so the user can enter the name of the new pokemon
        let alertController = UIAlertController(title: "New Pokemon", message: "Enter Pokemon Name:", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create and get the user action
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            // Get the new pokemon Name
            if let field = alertController.textFields![0] as? UITextField {
                // Check if the pokemon already exists if not then
                if !self.sh.doesExist(field.text!)
                {
                    // Set the name of the new pokemon
                    self.newPokemonName = field.text!
                    // Go to another view
                    self.performSegueWithIdentifier("newPokemon", sender: self)
                }
                else
                {
                    // Pokemon already in the pokedex.
                    self.showMessage("Pokedex Error", message: "Pokemon already registered in Pokedex.")
                }

            } else {
                // user did not fill field
            }
        }
        
        //Action for cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        //Set the inputbox placeholder
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Pokemon Name"
        }
        
        //Attach both actions to the controller
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //Set the alertbox layout style or else massive error will be shown in console about X, Y positions not being defined.
        alertController.view.setNeedsLayout()
        // Show the input alert to the user
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Function which created a new timer and schedules an event to happen every second.
    func checkIfPokemonExpired()
    {
        // Attach the timer to a defined variable, para1: seconds, para2, targer, para3 function to execute, para5 if repeats
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PokemonListController.updateCounting), userInfo: nil, repeats: true)
    }
    
    // Function which gets executed by the timer every second.
    func updateCounting(){
        // Check if all pokemons expired
        let expired = sh.hasExpired()
        
        // If pokemon expired
        if expired
        {
            // Reload table data
            self.pokedexTableView.reloadData()
            // Tell the user that the pokemon expired.
            self.showMessage("Pokemon Released", message: "Pokemon has been released.")
        }
    }
    
}