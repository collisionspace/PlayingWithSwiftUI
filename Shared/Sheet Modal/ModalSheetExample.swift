//
//  SheetModalExample.swift
//  SheetModalExample
//
//  Created by Daniel Slone on 14/8/21.
//

import SwiftUI

struct SheetModalExample: View {
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

struct SheetModalExample_Previews: PreviewProvider {
    static var previews: some View {
        SheetModal()
    }
}


extension View {
    func modalSheet<SheetView: View>(
        showSheet: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = .all,
        @ViewBuilder sheetView: @escaping () -> SheetView,
        onEnd: @escaping () -> () = {}) -> some View {
        background(
            HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet, detents: detents, onEnd: onEnd)
        )
    }
}

private extension Array where Element == UISheetPresentationController.Detent {
    static let all: [UISheetPresentationController.Detent] = [
        .medium(),
        .large()
    ]
}

private struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView

    @Binding var showSheet: Bool

    var detents: [UISheetPresentationController.Detent]

    var onEnd: () -> ()

    let controller = UIViewController()

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet {
            let sheetController = CustomHostingController(rootView: sheetView, detents: detents)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        } else {
            uiViewController.dismiss(animated: true)
        }
    }

    //on dismiss
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {

        var parent: HalfSheetHelper

        init(parent: HalfSheetHelper) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}

private final class CustomHostingController<Content: View>: UIHostingController<Content> {

    private let detents: [UISheetPresentationController.Detent]

    init(rootView: Content, detents: [UISheetPresentationController.Detent]) {
        self.detents = detents
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = detents
            presentationController.prefersGrabberVisible = true
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = true
        }
    }
}
