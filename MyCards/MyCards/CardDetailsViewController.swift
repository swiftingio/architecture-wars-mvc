//
//  CardDetailsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

final class CardDetailsViewController: UIViewController {

    fileprivate var card: Card {
        didSet {
            front.image = card.front
            back.image = card.back
            name.text = card.name
        }
    }
    fileprivate let worker: CoreDataWorkerProtocol
    fileprivate var mode: Mode {
        didSet {
            configureNavigationItem()
            configureModeForViews()
            dump(self.card)
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
    fileprivate let createNew: Bool
    fileprivate var editButton: UIBarButtonItem!
    fileprivate var deleteButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate let toolbar = UIToolbar(frame: .zero)

    init(card: Card?, worker: CoreDataWorkerProtocol = CoreDataWorker()) {
        createNew = card == nil
        self.card = card ?? Card(name: "")
        self.worker = worker
        self.mode = !createNew ? .normal : .edit
        super.init(nibName: nil, bundle: nil)
        self.title = createNew ? .AddNewCard : .CardDetails
        editButton = UIBarButtonItem(barButtonSystemItem:
            .edit, target: self, action: #selector(editTapped))
        deleteButton = UIBarButtonItem(barButtonSystemItem:
            .trash, target: self, action: #selector(removeTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem:
            .cancel, target: self, action: #selector(cancelTapped))
        doneButton = UIBarButtonItem(barButtonSystemItem:
            .done, target: self, action: #selector(doneTapped))
        dump(self.card)
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
        name.text = card.name
        view.addSubview(name)
        front = makeCardView(with: card.front)
        front.tapped = { [unowned self] in self.frontTapped() }
        view.addSubview(front)
        back = makeCardView(with: card.back)
        back.tapped = { [unowned self] in self.backTapped() }
        view.addSubview(back)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexible, deleteButton, flexible]
        view.addSubview(toolbar)
    }

    fileprivate func configureConstraints() {

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let views: [String: Any] = [
            "name": name,
            "front": front,
            "back": back,
            "toolbar": toolbar,
        ]

        let visual = [
            "H:|-(20)-[name]-(20)-|",
            "V:|-(80)-[name(40)]-(20)-[front]-(20)-[back(==front)]",
            "H:|[toolbar]|",
            "V:[toolbar(40)]|",
            ]

        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: front, attribute: .height, relatedBy:
            .equal, toItem: front, attribute: .width,
                    multiplier: 1 / .cardRatio, constant: 0))
        visual.forEach {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: $0, options:
                [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        }

        NSLayoutConstraint.activate(constraints)
    }

    fileprivate func configureNavigationItem() {
        switch mode {
        case .normal:
            navigationItem.rightBarButtonItems = [editButton]
        case .edit:
            navigationItem.rightBarButtonItems = [doneButton]
        }
        navigationItem.leftBarButtonItem = cancelButton
    }

    fileprivate func configureModeForViews() {
        let editMode = mode == .edit
        name.resignFirstResponder()
        name.isUserInteractionEnabled = editMode
        name.placeholder = editMode ? .EnterCardName : .NoName
        front.photoCamera.isHidden = !editMode
        back.photoCamera.isHidden = !editMode
        toolbar.isHidden = createNew || !editMode
    }

    fileprivate func makeNameField() -> UITextField {
        let name = UITextField()
        name.delegate = self
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.placeholder = .EnterCardName
        name.returnKeyType = .done
        name.addTarget(self, action: #selector(nameChanged(sender:)), for: .editingChanged)
        return name
    }

    fileprivate func makeCardView(with image: UIImage?) -> CardView {
        let view = CardView(image: image)
        return view
    }

    @objc fileprivate func doneTapped() {
        //TODO: validate card before saving -> name, front, back
        worker.upsert(entities: [card]) { _ in }
        if createNew {
            dismiss()
        } else {
            mode = .normal
        }
    }

    @objc fileprivate func removeTapped() {
        print("remove")
        worker.remove(entities: [card]) { [weak self] error in
            error.flatMap { print("\($0)") }
            self?.dismiss()
        }
    }

    @objc fileprivate func cancelTapped() {
        if createNew || mode == .normal {
            dismiss()
        } else {
            mode = .normal
        }
    }

    @objc fileprivate func editTapped() {
        mode = .edit
    }

    @objc fileprivate func nameChanged(sender textField: UITextField) {
        guard let name = textField.text else { return }
        card = Card(identifier: card.identifier,
                    name: name,
                    front: card.front,
                    back: card.back)
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
        view.endEditing(true)
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
        view.endEditing(true)
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

    fileprivate func set(_ image: UIImage, for side: Card.Side) {
        switch side {
        case .front:
            card = Card(identifier: card.identifier,
                        name: card.name,
                        front: image,
                        back: card.back)
        case .back:
            card = Card(identifier: card.identifier,
                        name: card.name,
                        front: card.front,
                        back: image)
        }
    }
}

extension CardDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
        set(image, for: side)
        takingPhotoFor = nil
        dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }

    func navigationController(_ navigationController: UINavigationController, willShow
        viewController: UIViewController, animated: Bool) {
        viewController.title = .SelectCardPhoto
    }
}

extension CardDetailsViewController: PhotoCaptureViewControllerDelegate {

    func photoCaptureViewController(_ viewController: PhotoCaptureViewController, didTakePhoto image: UIImage) {
        guard
            let side = takingPhotoFor else { return }
        set(image, for: side)
        takingPhotoFor = nil
        dismiss()
    }
}
