//
//  PokemonPreviewController.swift
//  iOS_CW
//
//  Created by ADRIAN IWASZKIEWICZ (1502689) on 08/12/2016.
//  Copyright © 2016 ADRIAN IWASZKIEWICZ (1502689). All rights reserved.
//

import Foundation
import UIKit

class PokemonView: UIViewController {
    
    @IBOutlet weak var pokemonExpiry: UILabel!
    @IBOutlet weak var pokemonNameLbl: UILabel!
    @IBOutlet weak var _previewImage: UIImageView!
    @IBOutlet weak var pokemonHPBar: UIProgressView!
    @IBOutlet weak var pokemonType: UILabel!
    @IBOutlet weak var pokemonMovement: UILabel!
    @IBOutlet weak var pokemonAttack: UILabel!
    @IBOutlet weak var pokemonAttackSpeed: UILabel!
    @IBOutlet weak var pokemonDefence: UILabel!
    @IBOutlet weak var pokemonDefenceSpeed: UILabel!
    
    // Pokemon which is to be previewed
    var pokemonInSpotlight:String!
    // Attributed of the pokemon which is previewed
    var pokemonInSpotLightAttrs:NSDictionary!
    // Timer object
    var timer = NSTimer()
    
    // Overriding the default segue initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeTime()

        // Place pokemon name inside the label.
        pokemonNameLbl.text = pokemonInSpotlight

        // Create new NSURL object to download image of the pokemon
        let imageURL = NSURL(string: "https://img.pokemondb.net/artwork/"+pokemonInSpotlight.lowercaseString+".jpg")
        
         // Check if the imageURL is not null somehow
        if(imageURL != nil){

            // Try to download the image
            if let imagedData = NSData(contentsOfURL: imageURL!)
            {
                // Image downloaded, set it to image element
                self._previewImage.image = UIImage(data: imagedData)
            }
            else
            {
                // Image is not downloaded or error occured, substitute the image with a 'default' image of a pokeball
                self._previewImage.image = UIImage(named: "pokeball")
            }
        }
        
        // Set all pokemon attributed into labels the user to see
        self.pokemonType.text = "\(String(pokemonInSpotLightAttrs.valueForKey("Type")!)) Pokemon"
        self.pokemonAttack.text = String(pokemonInSpotLightAttrs.valueForKey("Attack")!)
        self.pokemonAttackSpeed.text = String(pokemonInSpotLightAttrs.valueForKey("Attack Speed")!)
        self.pokemonDefence.text = String(pokemonInSpotLightAttrs.valueForKey("Defence")!)
        self.pokemonDefenceSpeed.text = String(pokemonInSpotLightAttrs.valueForKey("Defence Speed")!)
        self.pokemonMovement.text = String(pokemonInSpotLightAttrs.valueForKey("Speed")!)
        self.pokemonHPBar.progress = Float((pokemonInSpotLightAttrs.valueForKey("HP")?.stringValue)!)! / Float((pokemonInSpotLightAttrs.valueForKey("MaxHP")?.stringValue)!)!
        if pokemonInSpotLightAttrs.valueForKey("Expiry") != nil
        {
            // Set the initial release time
            self.pokemonExpiry.text = String(pokemonInSpotLightAttrs.valueForKey("Expiry")!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Remove second from the pokemon
    func removeTime()
    {
        // Attach the timer to a defined variable, para1: seconds, para2, targer, para3 function to execute, para5 if repeats
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PokemonListController.updateCounting), userInfo: nil, repeats: true)
    }
    
    // Function which gets executed by the timer every second.
    func updateCounting(){
        // Get the current seconds left before pokemon is released
        if let oldExpiry = Int(self.pokemonExpiry.text!)
        {
            // Check if its still more than 0
            if oldExpiry > 0
            {
                // Set it to leftSeconds - 1 and pass it back to the label
                self.pokemonExpiry.text = String(oldExpiry - 1)
            }
            else
            {
                // Set it to 0 if expired
                self.pokemonExpiry.text = "0"
            } 
        }
        
    }

}