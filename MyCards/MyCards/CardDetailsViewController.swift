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
    
    init(card: Card?) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
        self.title = card == nil ? "Add new card" : "Card"
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
        view.backgroundColor = .green
        //TODO: V: [name text field] - [front] - [back]
    }
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    func doneTapped(sender: UIBarButtonItem) {
        dismiss()
    }
    
    func cancelTapped(sender: UIBarButtonItem) {
        dismiss()
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}
