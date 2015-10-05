//
//  CustomTableViewCell.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 10/4/15.
//  Copyright © 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Custom Table View Cell to improve the List View appearance

import UIKit

class CustomTableViewCell: UITableViewCell {
	
	// MARK: - Properties
	
	@IBOutlet weak var studentImage: UIImageView!
	@IBOutlet weak var studentLinkLabel: UILabel!
	@IBOutlet weak var studentLocationLabel: UILabel!
	@IBOutlet weak var studentNameLabel: UILabel!
}
