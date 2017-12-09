//
//  CardDetailsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit

final class CardDetailsViewController: UIViewController {

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
    fileprivate let loader: ResourceLoading

    // MARK: Views
    // codebeat:disable[TOO_MANY_IVARS]
    fileprivate lazy var editButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem:
        .edit, target: self, action: #selector(editTapped))
    fileprivate lazy var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem:
        .cancel, target: self, action: #selector(cancelTapped))
    fileprivate lazy var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem:
        .done, target: self, action: #selector(doneTapped))
    fileprivate lazy var front: CardView = CardView(image: self.card.front).with {
        $0.tapped = { [unowned self] in self.cardTapped(.front) }
    }
    fileprivate lazy var back: CardView = CardView(image: self.card.back) .with {
        $0.tapped = { [unowned self] in self.cardTapped(.back) }
    }
    fileprivate lazy var name: UITextField = UITextField.makeNameField().with {
        $0.text = self.card.name
        $0.delegate = self
        $0.addTarget(self, action: #selector(nameChanged(sender:)), for: .editingChanged)
    }
    fileprivate lazy var toolbar: UIToolbar = UIToolbar.constrained().with {
        let delete = UIBarButtonItem(barButtonSystemItem:
            .trash, target: self, action: #selector(removeTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        $0.items = [flexible, delete, flexible]
    }
    // codebeat:enable[TOO_MANY_IVARS]

    init(card: Card,
         mode: Mode = .normal,
         worker: CoreDataWorkerProtocol = CoreDataWorker(),
         loader: ResourceLoading = NetworkLoader.shared) {
        self.card = card
        self.mode = mode
        self.worker = worker
        self.loader = loader
        self.history.append(self.card)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureNavigationItem()
        configureModeForViews()
        configureConstraints()
    }
}

extension CardDetailsViewController {
    fileprivate func configureViews() {
        view.backgroundColor = .white
        view.addSubview(name)
        view.addSubview(front)
        view.addSubview(back)
        view.addSubview(toolbar)
    }

    fileprivate func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints.append(name.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80))
        constraints.append(name.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(name.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(front.leadingAnchor.constraint(equalTo: name.leadingAnchor, constant: 0))
        constraints.append(front.trailingAnchor.constraint(equalTo: name.trailingAnchor, constant: 0))
        constraints.append(front.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20))
        constraints.append(front.heightAnchor.constraint(equalTo: front.widthAnchor, multiplier: 1 / .cardRatio))
        constraints.append(back.topAnchor.constraint(equalTo: front.bottomAnchor, constant: 20))
        constraints.append(back.leadingAnchor.constraint(equalTo: front.leadingAnchor, constant: 0))
        constraints.append(back.trailingAnchor.constraint(equalTo: front.trailingAnchor, constant: 0))
        constraints.append(back.heightAnchor.constraint(equalTo: front.heightAnchor, constant: 0))
        constraints.append(toolbar.heightAnchor.constraint(equalToConstant: 40))
        constraints.append(toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
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
        persist(card)
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

    fileprivate func persist(_ card: Card) {
        guard card.isValid else { return }
        worker.upsert(entities: [card]) { [weak self, loader] error in
            loader.upload(object: [card], to: "/cards", parser: CardParser()) { _ in }

            guard let strongSelf = self, error == nil else { return }
            strongSelf.history.append(card)
        }
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
        var front: UIImage?
        var back: UIImage?
        switch side {
        case .front:
            front = image
            back = card.back
        case .back:
            front = card.front
            back = image
        }
        card = Card(identifier: card.identifier,
                    name: card.name,
                    front: front,
                    back: back)
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
                               didFinishPickingMediaWithInfo info: [String: Any]) {
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

    fileprivate func process(_ image: UIImage, for side: Card.Side) {
        defer { dismiss() }
        let width: CGFloat = 600
        let height: CGFloat = width / .cardRatio
        let size = CGSize(width: width, height: height)
        guard let resized = image.resized(to: size) else { return }
        set(resized, for: side)
    }
}

extension CardDetailsViewController: PhotoCaptureViewControllerDelegate {

    func photoCaptureViewController(_ viewController: PhotoCaptureViewController, didTakePhoto
        photo: UIImage, for side: Card.Side) {
        process(photo, for: side)
    }
}

extension CardDetailsViewController: CropViewControllerDelegate {

    func cropViewController(_ viewController: CropViewController, didCropPhoto photo: UIImage, for side: Card.Side) {
        process(photo, for: side)
    }
}
