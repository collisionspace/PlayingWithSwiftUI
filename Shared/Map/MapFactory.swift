//
//  MapWrapper.swift
//  MapWrapper
//
//  Created by Daniel Slone on 4/9/21.
//

import Foundation
import SwiftUI

protocol Test {
    associatedtype T: View
    var body: T { get }
}

struct MapWrapper: Test {

//    var content: () -> Content
//
//    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        VStack {
            
        }
//        content()
    }
}

import MapKit

struct MapFactory {
    enum MapProvider {
        case apple
    }

    static func createView(provider: MapProvider, mapRect: Binding<MKMapRect>, visibleAnnotationItems: [BikeShareAnnotation]) -> AnyView {
        switch provider {
        case .apple:
            return AnyView(
                Map(mapRect: mapRect, annotationItems: visibleAnnotationItems) { item in
                    MapAnnotation(coordinate: item.city.coordinate) {
                        Image(systemName: "bicycle")
                        .onTapGesture(count: 1, perform: {
                            print("IT WORKS")
                      })
                    }
                }
            )
        }
    }
}
