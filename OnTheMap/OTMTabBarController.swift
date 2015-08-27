//
//  CustomTabBarController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {
	
	override func viewDidLoad() {
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "callInformationPostViewController:")
		self.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
	}
	
	func refresh(sender: AnyObject) {
		println("refresh")
	}
	
	func callInformationPostViewController(sender: AnyObject) {
		let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostViewController") as! UIViewController
		self.presentViewController(controller, animated: true, completion: nil)
	}
}