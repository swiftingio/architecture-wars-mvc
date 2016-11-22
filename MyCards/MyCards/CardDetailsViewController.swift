//
//  CardDetailsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CardDetailsViewController: UIViewController {

    fileprivate var card: Card?
    fileprivate let worker: CoreDataWorkerProtocol
    fileprivate var mode: Mode {
        didSet {
            configureNavigationItem()
            configureModeForViews()
        }
    }

    fileprivate var name: UITextField!
    fileprivate var front: CardView!
    fileprivate var back: CardView!
    fileprivate var takingPhotoFor: Card.Side?
let imagePicker = UIImagePickerController()

    init(card: Card?, worker: CoreDataWorkerProtocol = CoreDataWorker()) {
        self.card = card
        self.worker = worker
        self.mode = card != nil ? .normal : .edit
        super.init(nibName: nil, bundle: nil)
        self.title = card == nil ? .AddNewCard : card!.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureViews()
        configureModeForViews()
        configureConstraints()
    }
}

extension CardDetailsViewController {
    fileprivate func configureViews() {
        view.backgroundColor = .white
        name = makeNameField()
        view.addSubview(name)
        front = makeCardView(with: card?.front)
        front.tapped = { [unowned self] in self.frontTapped() }
        view.addSubview(front)
        back = makeCardView(with: card?.back)
        back.tapped = { [unowned self] in self.backTapped() }
        view.addSubview(back)
    }

    fileprivate func configureConstraints() {

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let views: [String: Any] = [
            "name": name,
            "front": front,
            "back": back
        ]

        let visual = [
            "V:|-(80)-[name(40)]-[front]-(20)-[back(==front)]-(60)-|",
            "H:|-(20)-[name]-(20)-|"
        ]

        var constraints: [NSLayoutConstraint] = []
        visual.forEach {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: $0, options:
                [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        }

        NSLayoutConstraint.activate(constraints)
    }

    fileprivate func configureNavigationItem() {
        switch mode {
        case .normal:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
                .edit, target: self, action: #selector(editTapped))
        case .edit:

            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
                .done, target: self, action: #selector(doneTapped))

        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            .cancel, target: self, action: #selector(cancelTapped))
    }

    fileprivate func configureModeForViews() {
        let editMode = mode == .edit
        name.resignFirstResponder()
        name.isUserInteractionEnabled = editMode
        front.photoCamera.isHidden = !editMode
        back.photoCamera.isHidden = !editMode
    }

    fileprivate func makeNameField() -> UITextField {
        let name = UITextField()
        name.delegate = self
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.placeholder = .EnterCardName
        name.returnKeyType = .done
        return name
    }

    fileprivate func makeCardView(with image: UIImage?) -> CardView {
        let view = CardView(image: image)
        return view
    }

    @objc fileprivate func doneTapped(sender: UIBarButtonItem) {
        //TODO: save & dismiss worker.save {}
        mode = .normal
    }

    @objc fileprivate func cancelTapped(sender: UIBarButtonItem) {
        dismiss()
    }

    @objc fileprivate func editTapped(sender: UIBarButtonItem) {
        mode = .edit
    }

    fileprivate func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    fileprivate func frontTapped() {
        switch mode {
        case .edit: showImagePickerSources(for: .front)
        case .normal: break //TODO: open large image

        }
    }

    fileprivate func backTapped() {
        switch mode {
        case .edit: showImagePickerSources(for: .back)
        case .normal: break //TODO: open large image
        }
    }

    fileprivate func showImagePickerSources(for side: Card.Side) {
        let title: String = .Set + " " + side.description
        let actionSheet = UIAlertController(title: title, message:
            nil, preferredStyle: .actionSheet)

        let actions: [UIImagePickerControllerSourceType] = UIImagePickerController.availableImagePickerSources()

        actions.forEach { source in
            let action = UIAlertAction(title: source.description, style:
            .default) { [unowned self] _ in
                self.showImagePicker(sourceType: source)
                self.takingPhotoFor = side
            }
            actionSheet.addAction(action)
        }

        let cancel = UIAlertAction(title: .Cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }

    private func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = PhotoCaptureViewController()
imagePicker.delegate = self
//        imagePicker.sourceType = sourceType
//        imagePicker.allowsEditing = true
//        imagePicker.delegate = self
//        imagePicker.view.backgroundColor = .white
////        imagePicker.showsCameraControls = false
        //TODO: use AV Foundation https://www.raywenderlich.com/30200/avfoundation-tutorial-adding-overlays-and-animations-to-videos
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height:
//            0.7 * imagePicker.view.bounds.height))
//        view.center = self.view.center
//        view.layer.cornerRadius = 5
//        view.layer.borderWidth = 2
//        view.layer.borderColor = UIColor.white.cgColor
//
//        let button = PhotoCamera(frame: .zero)
//        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takePhoto)))
//        button.center = view.center
//        button.sizeToFit()
//        button.frame.origin.y = imagePicker.view.bounds.height - button.intrinsicContentSize.height - 20
//        view.addSubview(button)

//        imagePicker.cameraOverlayView = view
        present(imagePicker, animated: true, completion: nil)
    }

    func takePhoto() {
        imagePicker.takePicture()
    }

    //TODO: handle rotation
}

extension CardDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //TODO: update card name
        return true
    }
}
extension CardDetailsViewController {
    enum Mode {
        case normal
        case edit
    }
}

extension CardDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
        let side = takingPhotoFor else { return }
        //TODO: open picture edit view
        switch side {
        case .front: front.image = image
        case .back: back.image = image
        }
        takingPhotoFor = nil
        dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }
}

extension CardDetailsViewController: PhotoCaptureDelegate {
    func photoTaken(_ data: Data) {
        guard
            let side = takingPhotoFor,
            let image = UIImage(data: data) else { return }
        //TODO: open picture edit view
        switch side {
        case .front: front.image = image
        case .back: back.image = image
        }
        takingPhotoFor = nil
        dismiss()    }
}
