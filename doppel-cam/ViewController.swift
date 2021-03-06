//
//  ViewController.swift
//  doppel-cam
//
//  Created by Dhruv and Melanie on 3/17/16.
//  Copyright © 2016 Dhruv. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    var pickedImage = UIImage()
    var newMedia: Bool?
    var stillImageOutput = AVCaptureStillImageOutput()
    var task:NSURLSessionTask?
    let camera = AVCaptureSession();
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    var device : AVCaptureDevice?
    var previewLayer = AVCaptureVideoPreviewLayer(session: nil);
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    
    
    
    override func viewDidLoad() {
        print("The view has loaded")
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
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        print("Refresh to camera")
        self.callRefresh()
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPoint = touches.first! as UITouch
        let screenSize = UIScreen.mainScreen().bounds.size
        let mathX = touchPoint.locationInView(self.view).y / screenSize.height
        let mathY = touchPoint.locationInView(self.view).x / screenSize.width
        let focusPoint = CGPoint(x: mathX, y: mathY)
        
            do{
                if let dev = device {
                    try dev.lockForConfiguration()
                    if dev.focusPointOfInterestSupported {
                        dev.focusPointOfInterest = focusPoint
                        dev.focusMode = AVCaptureFocusMode.AutoFocus
                        dev.exposurePointOfInterest = focusPoint
                        dev.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                        print(focusPoint)
                    }
                    if dev.exposurePointOfInterestSupported {
                        dev.exposurePointOfInterest = focusPoint
                        dev.exposureMode = AVCaptureExposureMode.AutoExpose
                    }
                    dev.unlockForConfiguration()
            
                }
            }catch _{
                print("bigerror")
            }

    }
    

    
    
    func beginSession(){
        print("The session has begun")
        
        do {
            configureDevice()
            try camera.addInput(AVCaptureDeviceInput(device:device));
            
        }catch let error as NSError{
            print("error attaching camera:")
            print(error);
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: camera);
        self.view.layer.addSublayer(previewLayer);
        previewLayer?.frame = self.view.layer.frame
        previewLayer?.zPosition = -1
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if camera.canAddOutput(stillImageOutput) {
            camera.addOutput(stillImageOutput)
        }
        print("the camera is now working")
        camera.startRunning();
    }
    
    @IBAction func refresh(sender: AnyObject) {
        callRefresh()
    }
    func configureDevice() {
        do{
            if let dev = device {
                try dev.lockForConfiguration()
                dev.focusMode = AVCaptureFocusMode.AutoFocus
                dev.unlockForConfiguration()
            }
        }catch _{
            print("error configuring device and 9/11 was an inside job btw")
        }
    }
    
    
 
    
    
    func callRefresh(){
        self.imageView.image = nil
        self.pickedImage = UIImage()

        self.task?.cancel()

        if let inpts = self.camera.inputs as? [AVCaptureDeviceInput]{
            for input in inpts {
                self.camera.removeInput(input)
            }
        }
        

        self.viewDidLoad()
        self.viewWillAppear(false)
    }

    @IBAction func useCamera(sender: AnyObject) {
        
    
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo){
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: imageData,scale:1.0)
                self.pickedImage = image!
                self.imageView.image = image!
                //Save the captured preview to image
                //UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                self.camera.stopRunning()


                self.upload(image!)
             
            
            
            })
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
        
        let request = NSMutableURLRequest(URL: NSURL(string:"https://doppel.camera/app/api/photo")!);
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
        
        self.task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            
            guard data != nil else{
               
                dispatch_async(dispatch_get_main_queue(), {
                    self.callRefresh()
                })
                print("http error")
                return
            }
           
            
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
        self.task?.resume() // this is needed to start the task
    
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

