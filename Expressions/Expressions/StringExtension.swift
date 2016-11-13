//
//  StringExtension.swift
//  Expressions
//
//  Created by Christian Lundtofte on 13/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

extension String {
    func charAt(index: Int) -> Character {
        let c = self[self.index(self.startIndex, offsetBy: index)]
        return c
    }
}
