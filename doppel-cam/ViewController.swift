//
//  ViewController.swift
//  doppel-cam
//
//  Created by Dhruv on 3/17/16.
//  Copyright © 2016 Dhruv. All rights reserved.
//

import UIKit
import MobileCoreServices
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    var newMedia: Bool?
    
    @IBAction func useCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .Camera
            
            self.presentViewController(picker, animated: true,
                completion: nil)
        
        
            newMedia = true;
            
        }
        
        
    }
    @IBAction func useCameraRoll(sender: AnyObject) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
        newMedia = false;
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func  imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
                
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = image
            
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        upload(image)
    }
    
    
    
    func upload(image: UIImage){
        
        let request = NSMutableURLRequest(URL: NSURL(string:"http://localhost:3000/app/api/photo")!);
        let session = NSURLSession.sharedSession()
       
        request.HTTPMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("superspecial", forHTTPHeaderField: "bar")

        
        
        let imageData = UIImageJPEGRepresentation(image, 0.9)

        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));

        
        let params = ["image":[ "content_type": "image/jpeg", "filename":"test.jpg", "file_data": base64String]]
        
        
        do {
            let message = try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
         
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        print("request.HTTPBody:")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            
            print("error:")
            print(error)
            
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding);
            print("we're complete: ")
            print(strData);
            
            
            
            
            
            // process the response
        })
        task.resume() // this is needed to start the task
    
    }
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

