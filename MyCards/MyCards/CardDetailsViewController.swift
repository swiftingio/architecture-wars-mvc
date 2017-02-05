//
//  CardDetailsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit

final class CardDetailsViewController: PortraitViewController {

    fileprivate var history: [Card] = []
    fileprivate var card: Card {
        didSet {
            front.image = card.front
            back.image = card.back
            name.text = card.name
            doneButton.isEnabled = card.isValid
        }
    }
    fileprivate var mode: Mode {
        didSet {
            configureNavigationItem()
            configureModeForViews()
        }
    }
    fileprivate let worker: CoreDataWorkerProtocol

    // MARK: Views
    // codebeat:disable[TOO_MANY_IVARS]
    fileprivate var name: UITextField!
    fileprivate var front: CardView!
    fileprivate var back: CardView!
    fileprivate var editButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate let toolbar = UIToolbar(frame: .zero)
    // codebeat:enable[TOO_MANY_IVARS]

    init(card: Card,
         mode: Mode = .normal,
         worker: CoreDataWorkerProtocol = CoreDataWorker()) {
        self.card = card
        self.worker = worker
        self.mode = mode
        self.history.append(self.card)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeAndConfigureViews()
        configureNavigationItem()
        configureModeForViews()
        configureConstraints()
    }
}

extension CardDetailsViewController {
    fileprivate func makeAndConfigureViews() {
        editButton = UIBarButtonItem(barButtonSystemItem:
            .edit, target: self, action: #selector(editTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem:
            .cancel, target: self, action: #selector(cancelTapped))
        doneButton = UIBarButtonItem(barButtonSystemItem:
            .done, target: self, action: #selector(doneTapped))

        view.backgroundColor = .white
        name = UITextField.makeNameField()
        name.text = card.name
        name.delegate = self
        name.addTarget(self, action: #selector(nameChanged(sender:)), for: .editingChanged)
        view.addSubview(name)
        front = CardView(image: card.front)
        front.tapped = { [unowned self] in self.cardTapped(.front) }
        view.addSubview(front)
        back = CardView(image: card.back)
        back.tapped = { [unowned self] in self.cardTapped(.back) }
        view.addSubview(back)
        let deleteButton = UIBarButtonItem(barButtonSystemItem:
            .trash, target: self, action: #selector(removeTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexible, deleteButton, flexible]
        view.addSubview(toolbar)
    }

    fileprivate func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints.append(name.topAnchor.constraint(equalTo: view.topAnchor, constant: 80))
        constraints.append(name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20))
        constraints.append(name.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20))
        constraints.append(front.leftAnchor.constraint(equalTo: name.leftAnchor, constant: 0))
        constraints.append(front.rightAnchor.constraint(equalTo: name.rightAnchor, constant: 0))
        constraints.append(front.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20))
        constraints.append(front.heightAnchor.constraint(equalTo: front.widthAnchor, multiplier: 1 / .cardRatio))
        constraints.append(back.topAnchor.constraint(equalTo: front.bottomAnchor, constant: 20))
        constraints.append(back.leftAnchor.constraint(equalTo: front.leftAnchor, constant: 0))
        constraints.append(back.rightAnchor.constraint(equalTo: front.rightAnchor, constant: 0))
        constraints.append(back.heightAnchor.constraint(equalTo: front.heightAnchor, constant: 0))
        constraints.append(toolbar.heightAnchor.constraint(equalToConstant: 40))
        constraints.append(toolbar.leftAnchor.constraint(equalTo: view.leftAnchor))
        constraints.append(toolbar.rightAnchor.constraint(equalTo: view.rightAnchor))
               NSLayoutConstraint.activate(constraints)
    }

    fileprivate func configureNavigationItem() {
        title = mode == .create ? .AddNewCard : .CardDetails
        doneButton.isEnabled = card.isValid
        switch mode {
        case .normal:
            navigationItem.rightBarButtonItems = [editButton]
        case .edit, .create:
            navigationItem.rightBarButtonItems = [doneButton]
        }
        navigationItem.leftBarButtonItem = cancelButton
    }

    fileprivate func configureModeForViews() {
        let editMode = mode != .normal
        name.resignFirstResponder()
        name.isUserInteractionEnabled = editMode
        name.placeholder = editMode ? .EnterCardName : .NoName
        front.photoCamera.isHidden = !editMode
        back.photoCamera.isHidden = !editMode
        toolbar.isHidden = !(mode == .edit)
    }

    @objc fileprivate func doneTapped() {
        guard card.isValid else { return }
        worker.upsert(entities: [card]) { [weak self] error in
            guard let strongSelf = self, error == nil else { return }
            strongSelf.history.append(strongSelf.card)
        }
        switch mode {
        case .create: dismiss()
        default: mode = .normal
        }
    }

    @objc fileprivate func removeTapped() {
        worker.remove(entities: [card]) { [weak self] error in
            error.flatMap { print("\($0)") }
            self?.dismiss()
        }
    }

    @objc fileprivate func cancelTapped() {
        switch mode {
        case .create, .normal: dismiss()
        case .edit:
            history.last.flatMap { card = $0 }
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

    fileprivate func cardTapped(_ side: Card.Side) {
        switch mode {
        case .edit, .create: showImagePickerSources(for: side)
        case .normal: showImage(for: side)
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
                self.showImagePicker(sourceType: source, for: side)
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

    private func showImagePicker(sourceType: UIImagePickerControllerSourceType, for side: Card.Side) {
        let imagePicker: UIViewController
        if sourceType == .camera {
            imagePicker = PhotoCaptureViewController(side: side).with {
                $0.delegate = self
            }
        } else {
            imagePicker = ImagePickerController().with {
                $0.delegate = self
                $0.view.backgroundColor = .white
                $0.side = side
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
        case create
    }
}

extension CardDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let side = (picker as? ImagePickerController)?.side else { return }
        showImageCropping(for: image, side: side)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }

    func navigationController(_ navigationController: UINavigationController, willShow
        viewController: UIViewController, animated: Bool) {
        viewController.title = .SelectCardPhoto
    }

    fileprivate func showImageCropping(for image: UIImage = #imageLiteral(resourceName: "background"),
                                       side: Card.Side) {
        let vc = CropViewController(image: image, side: side)
        vc.delegate = self
        dismiss(animated: true) {
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension CardDetailsViewController: PhotoCaptureViewControllerDelegate {

    func photoCaptureViewController(_ viewController: PhotoCaptureViewController, didTakePhoto
        image: UIImage, for side: Card.Side) {
        set(image, for: side)
        dismiss()
    }
}

extension CardDetailsViewController: CropViewControllerDelegate {

    func cropViewController(_ viewController: CropViewController, didCropPhoto photo: UIImage, for side: Card.Side) {
        set(photo, for: side)
    }
}
