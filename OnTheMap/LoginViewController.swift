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

// problemas
// - muito codigo repetido
// - nao existe timeout para o caso de 100% packet loss
// -- entre mapview e listview
// -- os botoes adicionados no viewWillAppear
// -- duvida sobre como fazer bom uso da conexao de internet (talvez usando threads)
// - uma custom view poderia ser criada para loading screen
// - overwrite? no app pode fazer isso, mas nao achei nada na rubric nem na especificacao
// - mais informacao sobre as APIs (possiveis codigos de retorno, por exemplo, seriam interessantes
// - POST and PUT (and all related methods) should probably be better organized because they are very similar
// -- Your update seems to be doing the same thing as the post
// - FindOnTheMapButtonTouch is very complicated
// - Timeout para internet?
// - Couldn't think in a way to optmize the requests
//
// - ERRO: AS LOADING SCREEN DEVEM SAIR QUANDO OCORRE ALGUM ERRO

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: - Outlets

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginWithUdacityButton: UIButton!
	
	// MARK: - Class variables
	
	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Configure the UI */
		self.configureUI()
		emailTextField.delegate = self
		passwordTextField.delegate = self
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
	}
	
	// MARK: - Actions
	
	/* Identifies which button was touched and selects the correct login method (Udacity or Facebook) */
	@IBAction func loginButtonTouch(sender: AnyObject) {
		
		loadingScreen.setActive(true)
		
		/* Hides keyboard */
		emailTextField.resignFirstResponder()
		passwordTextField.resignFirstResponder()
		
		/* Selecting the correct login method */
		if sender.tag == ButtonTags.UdacityLoginButtonTag {
			UdacityClient.sharedInstance().authenticateWithUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
				if success {
					self.loadingScreen.setActive(false)
					self.completeLogin()
				} else {
					ErrorDisplay.displayErrorWithTitle("Login Failed", errorDescription: errorString as! String, inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
				}
			}
		} else if sender.tag == ButtonTags.FacebookLoginButtonTag {
			// TODO: AUTHENTICATE WITH FACEBOOK
			//UdacityClient.sharedInstance().authenticateWithFacebook()
		} else {
			println("Unidentified button tag")
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
		let facebookButtonFrame = CGRect(x: self.view.center.x - loginWithUdacityButton.frame.width / 2, y: self.view.center.y + 174, width: loginWithUdacityButton.frame.width, height: loginWithUdacityButton.frame.height)
		let loginWithFacebookButton = FBSDKLoginButton(frame: facebookButtonFrame)
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
