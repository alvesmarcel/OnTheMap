//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginWithUdacityButton: UIButton!
	
	var session: NSURLSession!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Get the shared URL session */
		session = NSURLSession.sharedSession()
		
		/* Configure the UI */
		self.configureUI()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	// MARK: - Actions
	
	/* Identifies which button was touched and selects the correct login method (Udacity or Facebook) */
	@IBAction func loginButtonTouch(sender: AnyObject) {
		if let tag = sender.tag {
			if tag == UdacityClient.Constants.udacityLoginButtonTag {
				UdacityClient.sharedInstance().authenticateWithUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
					if success {
						self.completeLogin()
					} else {
						self.displayError(errorString as? String)
					}
				}
			} else if tag == UdacityClient.Constants.facebookLoginButtonTag {
				UdacityClient.sharedInstance().authenticateWithFacebook()
			} else {
				println("Unidentified button tag")
			}
		}
	}
	
	// MARK: - LoginViewController
	
	func completeLogin() {
		dispatch_async(dispatch_get_main_queue(), {
			println(UdacityClient.sharedInstance().sessionID)
			println(UdacityClient.sharedInstance().userID)
			let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OTMNavigationController") as! UINavigationController
			self.presentViewController(controller, animated: true, completion: nil)
		})
	}
	
	func displayError(errorString: String?) {
		dispatch_async(dispatch_get_main_queue()) {
			if let errorString = errorString {
				let alertController = UIAlertController(title: "Login Failed", message: "An error has ocurred\n" + errorString, preferredStyle: .Alert)
				let DismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
				alertController.addAction(DismissAction)
				self.presentViewController(alertController, animated: true) {}
			}
		}
	}
	
	func configureUI() {
		/* Configure background gradient */
		self.view.backgroundColor = UIColor.clearColor()
		let colorTop = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0).CGColor
		let colorBottom = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0).CGColor
		var backgroundGradient = CAGradientLayer()
		backgroundGradient.colors = [colorTop, colorBottom]
		backgroundGradient.locations = [0.0, 1.0]
		backgroundGradient.frame = view.frame
		self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
		
		/* Text fields text colors */
		emailTextField.textColor = UIColor(red: 1.0, green:0.4, blue:0.0, alpha: 1.0)
		passwordTextField.textColor = UIColor(red: 1.0, green:0.4, blue:0.0, alpha: 1.0)
		
		/* Configure Udacity login button */
		loginWithUdacityButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 17.0)
		loginWithUdacityButton.backgroundColor = UIColor(red: 1.0, green:0.4, blue:0.0, alpha: 1.0)
		loginWithUdacityButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
	}
}
