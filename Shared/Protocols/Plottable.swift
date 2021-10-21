//
//  Plottable.swift
//  Plottable
//
//  Created by Daniel Slone on 5/9/21.
//

import Foundation

protocol Plottable {
    var id: UUID { get }
    var title: String { get }
    var point: Coordinate { get }
}

protocol Clusterable: Plottable { }

typealias Annotatable = Identifiable & Clusterable
