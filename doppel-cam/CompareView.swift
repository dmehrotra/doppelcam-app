//
//  CompareView.swift
//  doppel-cam
//
//  Created by Dhruv on 4/14/16.
//  Copyright © 2016 Dhruv. All rights reserved.
//

import Foundation
import UIKit
import Social
class Compare:UIViewController{
    
    @IBOutlet weak var doppelPic: UIImageView!
    
    @IBOutlet weak var chosenPic: UIImageView!
    
    var doppelImage = UIImage()
    var chosenImage = UIImage()
    var composite = UIImage()
    override func viewDidLoad() {
        doppelPic.image = doppelImage
        chosenPic.image = chosenImage
        takeScreenshot();
        
    }
    @IBAction func shareToFacebook(){
        
        let shareToFacebook: SLComposeViewController =
        SLComposeViewController(forServiceType:
            SLServiceTypeFacebook)
     
        shareToFacebook.addImage(composite)
        
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
        
    }
    @IBAction func shareToTwitter(){
    
        let shareToTwitter: SLComposeViewController =
        SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        shareToTwitter.addImage(composite)
        self.presentViewController(shareToTwitter, animated: true, completion: nil)
        
    }

    func takeScreenshot() {
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(375,450), false, 0);
        self.view.drawViewHierarchyInRect(CGRectMake(0,-150,view.bounds.size.width,view.bounds.size.height), afterScreenUpdates: true)
        
        composite = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    
    


 
}