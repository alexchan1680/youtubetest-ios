//
//  Then.swift
//  YoutubeTest
//
//  Created by Alex on 11/3/2016.
//

import Foundation

import Foundation

protocol Then {}

extension Then {
    func then(@noescape block: Self -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}