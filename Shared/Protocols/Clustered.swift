//
//  Clustered.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import UIKit.UIImage

protocol Clustered: Clusterable {
    var clusterCount: Int { get }
    var image: UIImage? { get }
}
