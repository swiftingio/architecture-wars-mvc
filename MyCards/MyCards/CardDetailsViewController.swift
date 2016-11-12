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
    private let emptyScreen: UIImageView = UIImageView(image: #imageLiteral(resourceName: "bluebird"))
    //TODO: Edit Mode in initalizer
//    private let mode: Mode

    init(card: Card?, worker: CoreDataWorkerProtocol = CoreDataWorker()) {
        self.card = card
        self.worker = worker
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
        configureConstraints()
    }

    func configureViews() {
        view.backgroundColor = .white
        view.addSubview(emptyScreen)
    }

    func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints = NSLayoutConstraint.centerInSuperview(emptyScreen)
        //TODO: "V:|-[name]-(>=10)-[front]-[back]-|"
        NSLayoutConstraint.activate(constraints)
    }

    func configureNavigationItem() {
        //TODO: cancel edit in normal mode
        //TODO: cancel done in edit mode
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            .cancel, target: self, action: #selector(cancelTapped))
    }

    func doneTapped(sender: UIBarButtonItem) {
        //TODO: save & dismiss worker.save {}
        dismiss()
    }

    func cancelTapped(sender: UIBarButtonItem) {
        dismiss()
    }

    func editTapped(sender: UIBarButtonItem) {
        //TODO: edit mode on: text field enabled, front/back have photo camera button
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func frontTapped() {
    }

    func backTapped() {
    }

    //TODO: show camera picker when tapping on photo camera button

    //TODO: get picture back from camera and set to front/back

    //TODO: tap on front/back & open larger view

    //TODO: handle rotation
}
