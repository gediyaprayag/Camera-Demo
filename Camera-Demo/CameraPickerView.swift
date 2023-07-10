//
//  CameraPickerView.swift
//  Camera-Demo
//
//  Created by Prayag Gediya on 08/07/23.
//

import SwiftUI
import AVFoundation

struct CameraPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    let onImageTaken: (UIImage?) -> Void
    @State var picker = VolumeImagePickerController()
    @State private var imageTaken = false
    @State private var capturedImage: UIImage?
    @State private var isProccessing = false

    public init(onImageTaken: @escaping (UIImage?) -> Void) {
        self.onImageTaken = onImageTaken
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.showsCameraControls = false

        var config = UIButton.Configuration.bordered()
        config.buttonSize = .large
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 46
                                                                    ))
        config.image = UIImage(systemName: "circle.fill", withConfiguration: imageConfig)

        let overlayView = UIView(frame: picker.cameraOverlayView!.frame)
        let shutterButton = UIButton(configuration: config)
        shutterButton.layer.borderColor = UIColor.white.cgColor
        shutterButton.layer.borderWidth = 4
        shutterButton.layer.cornerRadius = 37
        shutterButton.tintColor = .white
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.addTarget(context.coordinator, action: #selector(Coordinator.takePhoto(_:)), for: .touchUpInside)
        overlayView.addSubview(shutterButton)
        shutterButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 74).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 74).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -100).isActive = true

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Close", for: .normal)
        cancelButton.layer.cornerRadius = 8.0
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        cancelButton.tintColor = .white
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(context.coordinator, action: #selector(Coordinator.cancel(_:)), for: .touchUpInside)
        overlayView.addSubview(cancelButton)
        if UIDevice.current.userInterfaceIdiom == .pad {
            cancelButton.leftAnchor.constraint(equalTo: shutterButton.rightAnchor, constant: 20).isActive = true
        } else {
            cancelButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -20).isActive = true

        }
        cancelButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor).isActive = true

        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(thumbnailImageView)
        thumbnailImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        thumbnailImageView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20).isActive = true
        thumbnailImageView.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor).isActive = true
        thumbnailImageView.isHidden = !imageTaken
        thumbnailImageView.image = capturedImage

        overlayView.isUserInteractionEnabled = true

        picker.cameraOverlayView = overlayView

        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Update the captured image thumbnail when the imageTaken state changes
        if let thumbnailImageView = uiViewController.cameraOverlayView?.subviews.compactMap({ $0 as? UIImageView }).first {
            thumbnailImageView.isHidden = !imageTaken
            thumbnailImageView.image = capturedImage
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let parent: CameraPickerView

        init(parent: CameraPickerView) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageTaken(image)
                parent.imageTaken = true
            }
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.parent.onImageTaken(nil)
        }

        @objc func takePhoto(_ sender: UIButton) {
            self.parent.picker.takePicture()
        }

        @objc func cancel(_ sender: UIButton) {
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }

    class VolumeImagePickerController: UIImagePickerController {
        deinit {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("_UIApplicationVolumeUpButtonDownNotification"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("_UIApplicationVolumeDownButtonDownNotification"), object: nil)
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            NotificationCenter.default.addObserver(self, selector: #selector(volumeButtonPressed(_:)), name: NSNotification.Name("_UIApplicationVolumeUpButtonDownNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(volumeButtonPressed(_:)), name: NSNotification.Name("_UIApplicationVolumeDownButtonDownNotification"), object: nil)
        }

        @objc func volumeButtonPressed(_ notification: Notification) {
            if let coordinator = delegate as? Coordinator {
                coordinator.takePhoto(UIButton())
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraPickerView(onImageTaken: { _ in })
        }
    }
}
