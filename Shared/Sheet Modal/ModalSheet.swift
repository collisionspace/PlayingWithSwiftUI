//
//  ModalSheet.swift
//  ModalSheet
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation
import SwiftUI

extension View {
    func modalSheet<SheetView: View>(
        showSheet: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = .all,
        @ViewBuilder sheetView: @escaping () -> SheetView,
        onEnd: @escaping () -> () = {}
    ) -> some View {
        background(
            ModalSheetHelper(
                sheetView: sheetView(),
                showSheet: showSheet,
                detents: detents,
                onEnd: onEnd
            )
        )
    }
}

private extension Array where Element == UISheetPresentationController.Detent {
    static let all: [UISheetPresentationController.Detent] = [
        .medium(),
        .large()
    ]
}

private struct ModalSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView

    @Binding var showSheet: Bool

    var detents: [UISheetPresentationController.Detent]

    var onEnd: () -> ()

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> HostingParentController<SheetView> {
        HostingParentController(
            rootView: sheetView,
            detents: detents,
            delegate: context.coordinator
        )
    }

    func updateUIViewController(_ viewController: HostingParentController<SheetView>, context: Context) {
        if showSheet {
            viewController.update(rootView: sheetView)
            viewController.show()
        } else {
            viewController.dismiss()
        }
    }

    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: ModalSheetHelper

        init(parent: ModalSheetHelper) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}

private final class HostingParentController<Content: View>: UIViewController {

    private var hostingController: CustomSheetHostingController<Content>
    private var isShown: Bool = false
    private var detents: [UISheetPresentationController.Detent]
    private var delegate: UISheetPresentationControllerDelegate {
        didSet {
            hostingController.presentationController?.delegate = delegate
        }
    }

    init(rootView: Content, detents: [UISheetPresentationController.Detent], delegate: UISheetPresentationControllerDelegate) {
        self.detents = detents
        self.hostingController = CustomSheetHostingController(
            rootView: rootView,
            detents: detents
        )
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // If its not already shown there could be an issue with constraints
    // making the sheet go all the way to the top so invalidating any previous
    // properties set by just going ahead and reiniting it if its not shown
    func update(rootView: Content) {
        if isShown {
            hostingController.rootView = rootView
        } else {
            hostingController = CustomSheetHostingController(
                rootView: rootView,
                detents: detents
            )
            hostingController.presentationController?.delegate = delegate
        }
    }

    func show() {
        if !isShown {
            isShown = true
            present(hostingController, animated: true)
        }
    }

    func dismiss() {
        isShown = false
        hostingController.dismiss(animated: true, completion: nil)
    }
}

private final class CustomSheetHostingController<Content: View>: UIHostingController<Content> {

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
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            presentationController.largestUndimmedDetentIdentifier = .medium
        }
    }
}
