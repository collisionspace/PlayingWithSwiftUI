//
//  ClusteredAnnotation.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import Foundation
import UIKit.UIImage

struct ClusteredAnnotation: Identifiable, Clustered {
    let id: UUID
    let title: String
    let point: Coordinate
    let iconName: String?
    let clusterCount: Int
    let image: UIImage?
    
    init(id: UUID = UUID(), title: String, point: Coordinate, iconName: String? = nil, clusterCount: Int, image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.point = point
        self.iconName = iconName
        self.clusterCount = clusterCount
        self.image = image
    }
}
