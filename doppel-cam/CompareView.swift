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
    @IBAction func shareToFacebook(){
        let shareToFacebook: SLComposeViewController =
        SLComposeViewController(forServiceType:
        SLServiceTypeFacebook)
        shareToFacebook.setInitialText(<#T##text: String!##String!#>)
        
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }
    @IBAction func shareToTwitter(){
        let shareToTwitter: SLComposeViewController =
        SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        self.presentViewController(shareToTwitter, animated: true, completion: nil)
        
    }
    var doppelImage = UIImage()
    var chosenImage = UIImage()

    override func viewDidLoad() {
        doppelPic.image = doppelImage
        chosenPic.image = chosenImage
        
    }
    
    func takeScreenshot(view: UIView) -> UIImageView {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        

        return UIImageView(image: image)
    }
    
    


 
}