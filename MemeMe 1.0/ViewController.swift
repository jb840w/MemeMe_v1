//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by 840west on 7/28/16.
//  Copyright © 2016 840west. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets, vars, constants
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    

    // MARK: View (willAppear, DidLoad, willDisappear)
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Does your device have a camera?
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Enable/Disable share button
        if imagePickerView.image == nil {
            actionButton.enabled = false
        } else {
            actionButton.enabled = true
        }
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // text field setup
        bottomTextField.delegate = self
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .Center
        topTextField.delegate = self
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions - choosing viewControllers(Camera, PhotoLibrary, Activity)
    
    // Action to choose the camera or album
    @IBAction func pickAnImage(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        // if statement, which picker was chosen
        if sender.tag == 0 {
            pickerController.sourceType = .Camera
            self.presentViewController(pickerController, animated: true, completion: nil)
        } else if sender.tag == 1 {
            pickerController.sourceType = .PhotoLibrary
            self.presentViewController(pickerController, animated: true, completion: nil)
        }
        
        
    }
    
    // Action to choose activity (share menu)
    @IBAction func activityShareAction(sender: UIBarButtonItem) {
        // Setting up and general iOS sharing
        let image = generateMemedImage()
        let itemsToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = []
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
        // Save the meme inside the app
        // Per honesty guidlines I found help with this code in a forum post with Abdallah_ElMenoufy & Danny46
        activityViewController.completionWithItemsHandler = {
            (activiy, success, items, error) in
            if success {
                self.saveMeme()
                print("Meme was saved 👍🏻")
                self.topToolBar.hidden = false
                self.bottomToolBar.hidden = false
            }
        }
        
    }
    
    // MARK: Actions - imagePicker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePickerView.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Actions / Attributes - TextFields
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0,
        
    ]
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // keep topTextField visible while editing / only change y value for bottomTextField
        if self.view.frame.origin.y == 0 && !topTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // only change y value if editing bottomTextField
        if !topTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: Save the Meme
    
    struct Meme {
        var topText: String
        var bottomText: String
        var image: UIImage
        var memedImage: UIImage
    }
    
    
    // Part of the learning but doesn't seem to be necessary yet with my build
    
    func saveMeme() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        topTextField.text = ""
        bottomTextField.text = ""
        imagePickerView.image = nil
    }

    


}

