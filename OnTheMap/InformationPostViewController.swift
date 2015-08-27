//
//  InformationPostViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit
import MapKit

class InformationPostViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {

	// MARK: - UIButtons
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var submitButton: UIButton!
	
	// MARK: - UILabels
	@IBOutlet weak var label1: UILabel!
	@IBOutlet weak var label2: UILabel!
	@IBOutlet weak var label3: UILabel!
	
	// MARK: - UITextFields
	@IBOutlet weak var locationTextField: UITextView!
	@IBOutlet weak var linkTextField: UITextView!
	
	// MARK: - MKMapView
	@IBOutlet weak var map: MKMapView!
	
	// MARK: - Helper variables
	var shouldCleanTextView: Bool!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		locationTextField.delegate = self
		linkTextField.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		configureLocationUI()
	}
	
	// MARK: - Actions
	@IBAction func cancelButtonTouch(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func findOnTheMapButtonTouch(sender: AnyObject) {
		configureLinkUI()
	}
	
	// MARK: - UITextFieldDelegate Methods
	
	/* Cleans text field when needed */
	func textViewDidBeginEditing(textView: UITextView) {
		if shouldCleanTextView == true {
			textView.text = ""
		}
		shouldCleanTextView = false
	}
	
	/* Hides keyboard when return key is touched */
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			
			if textView.text == "" {
				resetTextView()
			}
			
			return false
		}
		return true
	}
	
	// MARK: - Helper methods
	
	/* Puts the text field in the initial state */
	func resetTextView() {
		locationTextField.text = "Enter Your Location Here"
		linkTextField.text = "Enter a Link to Share Here"
		shouldCleanTextView = true
	}
	
	/* Configure the UI to present the "location screen" */
	func configureLocationUI() {
		resetTextView()
		
		label1.alpha = 1.0
		label2.alpha = 1.0
		label3.alpha = 1.0
		
		linkTextField.alpha = 0.0
		
		map.alpha = 0.0
		
		submitButton.setTitle("Find on the Map", forState: .Normal)
		cancelButton.titleLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.59, alpha: 1.0)
		
		self.view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1.0)
	}
	
	/* Configure the UI to presente the "link screen" */
	func configureLinkUI() {
		resetTextView()
		
		label1.alpha = 0.0
		label2.alpha = 0.0
		label3.alpha = 0.0
	
		linkTextField.alpha = 1.0
		
		map.alpha = 1.0
		
		submitButton.setTitle("Submit", forState: .Normal)
		cancelButton.titleLabel?.textColor = UIColor.whiteColor()
		
		self.view.backgroundColor = UIColor(red: 0.29, green: 0.57, blue: 0.75, alpha: 1.0)
	}
}