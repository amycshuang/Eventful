//
//  Filter.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/10/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation

class Filter {
    var filter: String
    var isSelected: Bool
    
    init(filter: String, isSelected: Bool) {
        self.filter = filter
        self.isSelected = isSelected
    }
}
