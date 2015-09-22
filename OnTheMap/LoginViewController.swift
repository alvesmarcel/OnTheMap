//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for the first screen in the app (the Login screen).
//  It's possible to realize the login using Udacity credentials or through Facebook API
//  Also, it is possible to be redirected to a website for signing up

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
	
	// MARK: - Outlets

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginWithUdacityButton: UIButton!
	
	// MARK: - Class variables
	
	var loginWithFacebookButton: FBSDKLoginButton!
	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Configure the UI */
		self.configureUI()
		emailTextField.delegate = self
		passwordTextField.delegate = self
		loginWithFacebookButton.delegate = self
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
	}
	
	// MARK: - Actions
	
	/* Realizes Udacity Login when the loginWithUdacityButton is touched */
	@IBAction func udacityLoginButtonTouch(sender: AnyObject) {
		
		loadingScreen.setActive(true)
		
		/* Hides keyboard */
		emailTextField.resignFirstResponder()
		passwordTextField.resignFirstResponder()
		
		UdacityClient.sharedInstance().authenticateWithUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
			if success {
				self.loadingScreen.setActive(false)
				self.completeLogin()
			} else {
				ErrorDisplay.displayErrorWithTitle("Login Failed", errorDescription: errorString as! String, inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
			}
		}
	}
	
	/* Sign up button. Opens Udacity URL in Safari */
	@IBAction func signUpButtonTouch(sender: AnyObject) {
		let url = NSURL(string: UdacityClient.Constants.SignUpURL)
		UIApplication.sharedApplication().openURL(url!)
	}
	
	// MARK: - TextFieldDelegate methods
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - FBSDKLoginButtonDelegate
	
	/* Performs everything necessary after the Facebook login is completed */
	func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
		println("aqui 1")
		if error != nil {
			println(error)
			println(error.localizedDescription)
			/* There was an error trying to log in with Facebook */
			ErrorDisplay.displayErrorWithTitle("Login With Facebook Error", errorDescription: error.localizedDescription, inViewController: self, andDeactivatesLoadingScreen: nil)
		} else if result.isCancelled {
			// The login was cancelled - nothing need to be done
			println("cancelou")
		} else {
			println("aqui 2")
			/* Facebook login was successful - the app communicate with Udacity to complete the log in process */
			loadingScreen.setActive(true)
			UdacityClient.sharedInstance().authenticateWithFacebook() { success, errorString in
				if success {
					self.loadingScreen.setActive(false)
					self.completeLogin()
				} else {
					ErrorDisplay.displayErrorWithTitle("Error Communicating With Udacity", errorDescription: errorString as! String, inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
					dispatch_async(dispatch_get_main_queue()) {
						FBSDKLoginManager().logOut()
					}
				}
			}
		}
	}
	
	func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
		// Needed by FBSDKLoginButtonDelegate but not used
	}
	
	// MARK: - LoginViewController
	
	/* Login completed: sets loading screen not active and calls next view controller */
	func completeLogin() {
		dispatch_async(dispatch_get_main_queue(), {
			self.emailTextField.text = ""
			self.passwordTextField.text = ""
			let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OTMNavigationController") as! UINavigationController
			self.presentViewController(controller, animated: true, completion: nil)
		})
	}
	
	// MARK: UI Helper methods
	
	/* Performs some UI configuration */
	func configureUI() {
		
		/* Creating Facebook Button */
		let facebookButtonFrame = CGRect(
			x: self.view.center.x - loginWithUdacityButton.frame.width / 2,
			y: self.view.center.y + 174,
			width: loginWithUdacityButton.frame.width,
			height: loginWithUdacityButton.frame.height)
		loginWithFacebookButton = FBSDKLoginButton(frame: facebookButtonFrame)
		self.view.addSubview(loginWithFacebookButton)
		
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
