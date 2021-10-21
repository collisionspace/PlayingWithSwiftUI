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
            BikeShareMap(cities: $repo.cities)
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
            ShareList(cities: $repo.cities)
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

    @Binding var cities: [City]

    var body: some View {
        List(cities) {
            Text($0.name)
        }
    }
}
