//
//  CardDetailsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CardDetailsViewController: UIViewController {

    //TODO: implement empty screen - blue bird

    fileprivate var card: Card?
    fileprivate let worker: CoreDataWorkerProtocol
    //TODO: Edit Mode in initalizer
    
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
        configureView()
        configureNavigationItem()
    }

    func configureView() {
        view.backgroundColor = .white
        //TODO: "V:|-[name]-(>=10)-[front]-[back]-|"
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
