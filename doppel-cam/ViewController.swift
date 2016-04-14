//
//  ViewController.swift
//  doppel-cam
//
//  Created by Dhruv on 3/17/16.
//  Copyright © 2016 Dhruv. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    var pickedImage = UIImage()
    var newMedia: Bool?
    
    
    let camera = AVCaptureSession();
    var device : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.sessionPreset = AVCaptureSessionPresetLow
        let devices = AVCaptureDevice.devices()
        
        for d in devices {
            if (d.hasMediaType(AVMediaTypeVideo)){
                if(d.position == AVCaptureDevicePosition.Back){
                    device = d as? AVCaptureDevice;
                }
            }
        }
        if device != nil {
            beginSession();
        }
    }
    
    

 
    
    
    func beginSession(){
     
        do {
            try camera.addInput(AVCaptureDeviceInput(device:device));
        }catch let error as NSError{
            print(error);
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera);
        self.view.layer.addSublayer(previewLayer);
        previewLayer?.frame = self.view.layer.frame
        camera.startRunning();
    }
    
    @IBAction func refresh(sender: AnyObject) {
        pickedImage = UIImage()
        imageView.image = nil
        
        viewDidLoad()
        
        
    }
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
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func  imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
                
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        pickedImage = image
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
            
            let strData = String(data: data!, encoding: NSUTF8StringEncoding);
            print("we're complete: ")
            // convert string to json
            let dictionary = self.convertStringToDictionary(strData!);
            // if there is a url property do this:
            if let url = dictionary?["url"]{
                print(url);
                // go to the url
                if let img_url = NSURL(string: url) {
                    if let img_data = NSData(contentsOfURL: img_url) {
                        //print the original image just cuz im curious
                        //make imageview container's image the returned image from server;
                        // It needs to be placed inside a different thread that allows the UI to update:
                        dispatch_async(dispatch_get_main_queue(), {

                            self.imageView.image = UIImage(data: img_data)
                        })
                       
                    }        
                }
            }
            
        })
        task.resume() // this is needed to start the task
    
    }
    func convertStringToDictionary(text: String) -> [String:String]? {
      
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String:String]
                return json;
            }catch let error as NSError{
                print(error.localizedDescription);
            }
            
        }
        return nil
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let DestViewController : Compare = segue.destinationViewController as! Compare
        
        DestViewController.doppelImage = self.imageView.image!
    
        DestViewController.chosenImage = pickedImage
    
    }
}

