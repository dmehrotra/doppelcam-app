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

    override func viewDidLoad() {
        doppelPic.image = doppelImage
        chosenPic.image = chosenImage
        
    }
    @IBAction func shareToFacebook(){
//        let shareToFacebook: SLComposeViewController =
//        SLComposeViewController(forServiceType:
//            SLServiceTypeFacebook)
////        shareToFacebook.setInitialText(String!)
////        shareToFacebook.addImage(UIImage!)
//        
//        self.presentViewController(shareToFacebook, animated: true, completion: nil)
        takeScreenshot();
    }
    @IBAction func shareToTwitter(){
        let shareToTwitter: SLComposeViewController =
        SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        self.presentViewController(shareToTwitter, animated: true, completion: nil)
        
    }

    func takeScreenshot() {
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(500,600), false, 0);
        self.view.drawViewHierarchyInRect(CGRectMake(50,-50,view.bounds.size.width,view.bounds.size.height), afterScreenUpdates: true)
        
        chosenImage = UIGraphicsGetImageFromCurrentImageContext();
        chosenPic.image = chosenImage
    }
    
    


 
}