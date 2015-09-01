//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

// problemas
// - muito codigo repetido
// - nao existe timeout para o caso de 100% packet loss
// -- entre mapview e listview
// -- os botoes adicionados no viewWillAppear
// -- duvida sobre como fazer bom uso da conexao de internet (talvez usando threads)
// - uma custom view poderia ser criada para loading screen

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginWithUdacityButton: UIButton!
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

	var session: NSURLSession!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Get the shared URL session */
		session = NSURLSession.sharedSession()
		
		/* Configure the UI */
		self.configureUI()
		
		activityIndicatorView.hidesWhenStopped = true
		activateLoadingScreen(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	// MARK: - Actions
	
	/* Identifies which button was touched and selects the correct login method (Udacity or Facebook) */
	@IBAction func loginButtonTouch(sender: AnyObject) {
		activateLoadingScreen(true)
		if let tag = sender.tag {
			if tag == UdacityClient.Constants.udacityLoginButtonTag {
				UdacityClient.sharedInstance().authenticateWithUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
					if success {
						dispatch_async(dispatch_get_main_queue()) {
							self.activateLoadingScreen(false)
						}
						self.completeLogin()
					} else {
						self.displayError(errorString as? String)
					}
				}
			} else if tag == UdacityClient.Constants.facebookLoginButtonTag {
				// TODO: AUTHENTICATE WITH FACEBOOK
				//UdacityClient.sharedInstance().authenticateWithFacebook()
			} else {
				println("Unidentified button tag")
			}
		}
	}
	
	@IBAction func signUpButtonTouch(sender: AnyObject) {
		let url = NSURL(string: UdacityClient.Constants.signUpUrl)
		UIApplication.sharedApplication().openURL(url!)
	}
	
	// MARK: - LoginViewController
	
	func completeLogin() {
		dispatch_async(dispatch_get_main_queue(), {
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
	
	func activateLoadingScreen(active: Bool) {
		if active {
			loadingView.hidden = false
			activityIndicatorView.startAnimating()
		} else {
			loadingView.hidden = true
			activityIndicatorView.stopAnimating()
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
