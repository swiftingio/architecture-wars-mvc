//
//  CardDetailsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

final class CardDetailsViewController: UIViewController {

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
    override var shouldAutorotate: Bool { return false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

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
            "H:|-(20)-[name]-(20)-|",
            "V:|-(80)-[name(40)]-(20)-[front]-(20)-[back(==front)]",
        ]

        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: front, attribute: .height, relatedBy: .equal, toItem: front, attribute: .width, multiplier: 1 / .cardRatio, constant: 0))
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
        if card == nil {
            dismiss()
        } else {
            mode = .normal
        }
    }

    @objc fileprivate func cancelTapped(sender: UIBarButtonItem) {
        dismiss()
    }

    @objc fileprivate func editTapped(sender: UIBarButtonItem) {
        mode = .edit
    }

    fileprivate func frontTapped() {
        switch mode {
        case .edit: showImagePickerSources(for: .front)
        case .normal: showImage(for: .front)
        }
    }

    fileprivate func backTapped() {
        switch mode {
        case .edit: showImagePickerSources(for: .back)
        case .normal: showImage(for: .back)
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

    fileprivate func showImage(for side: Card.Side) {
        var image: UIImage?
        switch side {
        case .front: image = front.image
        case .back: image = back.image
        }
        guard let i = image else { return }
        let vc = CardPhotoViewController(image: i)
        present(vc, animated: true, completion: nil)
    }

    private func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker: UIViewController
        if sourceType == .camera {
            imagePicker = PhotoCaptureViewController().with {
                $0.delegate = self
            }
        } else {
            imagePicker = UIImagePickerController().with {
                $0.delegate = self
                $0.view.backgroundColor = .white
            }
        }
        present(imagePicker, animated: true, completion: nil)
    }
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

extension CardDetailsViewController: PhotoCaptureViewControllerDelegate {

    func photoCaptureViewController(_ viewController: PhotoCaptureViewController, didTakePhoto image: UIImage) {
        guard
            let side = takingPhotoFor else { return }
        //TODO: open picture edit view
        switch side {
        case .front: front.image = image
        case .back: back.image = image
        }
        takingPhotoFor = nil
        dismiss()
    }
}
