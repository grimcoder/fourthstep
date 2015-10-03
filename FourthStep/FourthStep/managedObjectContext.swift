//
//  managedObjectContext.swift
//  FourthStep
//
//  Created by Taras Kovtun on 9/29/15.
//  Copyright © 2015 Taras Kovtun. All rights reserved.
//

import Foundation
import UIKit

class ObjectContext{
    static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
}