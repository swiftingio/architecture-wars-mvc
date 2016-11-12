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
    fileprivate var front: UIImageView!
    fileprivate var back: UIImageView!

    init(card: Card?, worker: CoreDataWorkerProtocol = CoreDataWorker()) {
        self.card = card
        self.worker = worker
        self.mode = card != nil ? .normal : .edit
        super.init(nibName: nil, bundle: nil)
        self.title = card == nil ? "Add new card" : card!.name
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
        view.addSubview(front)
        back = makeCardView(with: card?.back)
        view.addSubview(back)
    }

    fileprivate func configureConstraints() {

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let views = [
            "name":name,
            "front":front,
            "back": back
        ]

        let visual = [
            "V:|-(==80)-[name(==40)]-[front]-(20)-[back(==front)]-(60)-|",
            "H:|-[name]-|"
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
        name.isUserInteractionEnabled = mode == .edit
        //TODO: front/back in edit mode
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

    fileprivate func makeCardView(with image: UIImage?) -> UIImageView {
        //TODO: make real card view; front/back have photo camera button
        let view = UIImageView(image: image)
        if image == nil {
            view.image = #imageLiteral(resourceName: "logo") //TODO: image placeholder
        }
        view.contentMode = .scaleAspectFit
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
    }

    fileprivate func backTapped() {
    }

    //TODO: show camera picker when tapping on photo camera button

    //TODO: get picture back from camera and set to front/back

    //TODO: tap on front/back & open larger view

    //TODO: handle rotation
}
extension CardDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text)
        return true
    }

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
