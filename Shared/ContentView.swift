//
//  ContentView.swift
//  Shared
//
//  Created by Daniel Slone on 14/8/21.
//

import SwiftUI

struct ContentView: View {
    @State var showSheet: Bool = false
    @ObservedObject var repo = BikeShareRepository()

    var body: some View {
        ZStack {
            BikeShareMap(annotations: $repo.annotations)
            .ignoresSafeArea()

            HStack {
                Spacer()

                // Button overlays
                VStack(alignment: .center, spacing: 16) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "info.circle").resizable()
                    }.frame(width: 32, height: 32)

                    Spacer()
                }
            }.padding(.trailing, 16).padding(.top, 16)
        }.modalSheet(showSheet: $showSheet) {
            ShareList(annotations: $repo.annotations)
        }.task {
            await repo.getBikeShareCities()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ShareList: View {

    @Binding var annotations: [BikeShareAnnotation]

    var body: some View {
        List(annotations) {
            Text($0.city.name)
        }
    }
}
