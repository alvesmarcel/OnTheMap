//
//  ErrorDisplay.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/7/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for exibiting an error in an alert view
//  It helps avoiding the repetition of the method displayError in all the view controllers

import UIKit

class ErrorDisplay {
	
	class func displayErrorWithTitle(title: String, errorDescription: String, inViewController viewController: UIViewController, andDeactivatesLoadingScreen loadingScreen: LoadingScreen?) {
		if let loadingScreen = loadingScreen {
			loadingScreen.setActive(false)
		}
		dispatch_async(dispatch_get_main_queue()) {
			let alertController = UIAlertController(title: title, message: "An error has ocurred\n" + errorDescription, preferredStyle: .Alert)
			let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
			alertController.addAction(dismissAction)
			viewController.presentViewController(alertController, animated: true) {}
		}
	}
}