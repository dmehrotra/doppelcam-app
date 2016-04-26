//
//  CompareView.swift
//  doppel-cam
//
//  Created by Dhruv on 4/14/16.
//  Copyright © 2016 Dhruv. All rights reserved.
//

import Foundation
import UIKit

class Compare:UIViewController{
    
    @IBOutlet weak var doppelPic: UIImageView!
    
    @IBOutlet weak var chosenPic: UIImageView!
   
    var doppelImage = UIImage()
    var chosenImage = UIImage()

    override func viewDidLoad() {
        doppelPic.image = doppelImage
        chosenPic.image = chosenImage
    }
    

    
    


 
}