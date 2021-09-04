//
//  ModalSheetExample.swift
//  ModalSheetExample
//
//  Created by Daniel Slone on 14/8/21.
//

import SwiftUI

struct ModalSheetExample: View {
    @State var showSheet: Bool = false

    var body: some View {
        NavigationView {
            Button {
                showSheet.toggle()
            } label: {
                Text("present")
            }
            .navigationTitle("half modal sheet")
            .modalSheet(showSheet: $showSheet) {
                ZStack {
                    Color.red

                    Text("Howdy")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                .ignoresSafeArea()
            } onEnd: {
                print("dismiss")
            }
        }
    }
}

struct ModalSheetExample_Previews: PreviewProvider {
    static var previews: some View {
        ModalSheetExample()
    }
}
