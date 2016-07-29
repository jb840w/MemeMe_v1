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
    
    // Setup delegate connection for meme Struct and storage
    // Per honesty guidlines I found help for this from StackOverFlow http://stackoverflow.com/questions/32810069/access-structure-in-swift-array
    
    let memeDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    

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
        
        // text field setup
        setTextField(topTextField)
        setTextField(bottomTextField)
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions - choosing viewControllers(Camera, PhotoLibrary, Activity)
    
    // Action to choose the camera or album
    @IBAction func pickAnImage(sender: AnyObject) {
        
        let senderOption = sender.tag
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        // I switched (no pun intended) this up from my original submission, switch seemed more clean than multiple if/else
        
        switch senderOption {
        case 0: // tag.0 is Camera
            pickerController.sourceType = .Camera
            self.presentViewController(pickerController, animated: true, completion: nil)
        case 1: // tag.1 is PhotoLibrary
            pickerController.sourceType = .PhotoLibrary
            self.presentViewController(pickerController, animated: true, completion: nil)
        case 2: // tag.3 is action button
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
                    self.topToolBar.hidden = false
                    self.bottomToolBar.hidden = false
                }
            }
        default:
            print("It doesn't look like you have chosen a viewController")
        }

    }
    
    
    // MARK: Actions - imagePicker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePickerView.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Actions / Attributes - TextFields
    
    // beautiful suggestion from review team that greatly simplifies these steps and kills a bit of the repetition
    func setTextField(textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center

    }
    
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
        if view.frame.origin.y == 0 && !topTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // only change y value if editing bottomTextField
        if view.frame.origin.y < 0 && !topTextField.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification)
            
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
    
    func saveMeme() {
        let meme = AppDelegate.Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: generateMemedImage())
        
        // now add it to the meme storage in my appdelegate 
        memeDelegate.memes.append(meme)
        print("Meme was saved 👍🏻")
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
    
    // MARK: Cancel Action - clears all contents, does not alter saved memes.

    @IBAction func cancel(sender: UIBarButtonItem) {
        topTextField.text = ""
        bottomTextField.text = ""
        imagePickerView.image = nil
    }

    


}

