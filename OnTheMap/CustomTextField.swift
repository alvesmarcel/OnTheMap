//
//  CustomTextField.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectMake(10, 0, 260, 100)
	}
	
	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectMake(10, 0, 260, 100)
	}
	
	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectMake(10, 0, 260, 100)
	}
	
}