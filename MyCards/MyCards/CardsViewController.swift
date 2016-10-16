//
//  CardsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

struct Card {
//    let name: String
//    let front: UIImage
//    let back: UIImage
}

class CardsViewController: UIViewController {

    fileprivate let worker: CoreDataWorkerProtocol
    fileprivate var cards: [Card] = []
    
    init(worker: CoreDataWorkerProtocol) {
        self.worker = worker
        super.init(nibName: nil, bundle: nil)
        self.title = "Cards"
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
        view.backgroundColor = .red
        //TODO: CollectionView
    }
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    func addTapped(sender: UIBarButtonItem) {
        showDetails(for: nil)
    }
    
    func showDetails(for card: Card?) {
        let viewController = CardDetailsViewController(card: card)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}
