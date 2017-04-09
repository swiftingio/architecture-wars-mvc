//
//  CardsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit

// MARK: - Lifecycle
final class CardsViewController: PortraitViewController {

    fileprivate let worker: CoreDataWorkerProtocol
    fileprivate let loader: ResourceLoading
    fileprivate let notificationCenter: NotificationCenterProtocol
    fileprivate lazy var cards: [Card] = []

    fileprivate var emptyScreen: UIImageView!
    fileprivate var collectionView: UICollectionView!
    fileprivate let reuseIdentifier: String = String(describing: CardCell.self)
    fileprivate var observer: NSObjectProtocol?

    init(worker: CoreDataWorkerProtocol = CoreDataWorker(),
         loader: ResourceLoading = NetworkLoader.shared,
         notificationCenter: NotificationCenterProtocol = NotificationCenter.default) {
        self.worker = worker
        self.loader = loader
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
        self.title = .MyCards
        observer = notificationCenter.observeChanges(for: CardMO.self) { [weak self] in
            self?.getCards()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    deinit {
        observer.flatMap { notificationCenter.removeObserver($0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        loadCards()
        getCards()
    }

    func loadCards() {
        //NOTE: python -m SimpleHTTPServer 8000 in the directory of `cards.json`
        loader.download(from: "/cards.json", parser: CardParser()) { [unowned self] (cards) in
            guard let cards = cards as? [Card] else { self.getCards(); return }
            self.worker.upsert(entities: cards) { [unowned self] (_) in
                self.getCards()
            }
        }
    }

    func getCards() {
        worker.get { [weak self] (result: Result<[Card]>) in
            guard let sself = self else { return }
            switch result {
            case .failure(_): break
            case .success(let cards):
                sself.cards = cards
                sself.reloadData()
            }
        }
    }

    func reloadData() {
        if !cards.isEmpty {
            hideEmptyScreen()
        } else {
            showEmptyScreen()
        }
        collectionView.reloadData()
    }
}

// MARK: - Configuration
extension CardsViewController {

    fileprivate func configureViews() {
        view.backgroundColor = . white
        view.clipsToBounds = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            .add, target: self, action: #selector(addTapped))

        emptyScreen = makeEmptyScreen()
        view.addSubview(emptyScreen)

        collectionView = UICollectionView.makeCollectionView(in: view.bounds)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    fileprivate func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.filledInSuperview(emptyScreen, padding: 44)
        constraints += NSLayoutConstraint.filledInSuperview(collectionView)
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Helpers
extension CardsViewController {

    fileprivate func makeEmptyScreen() -> UIImageView {
        let emptyScreen = UIImageView(image: #imageLiteral(resourceName: "MyCards"))
        emptyScreen.contentMode = .scaleAspectFit
        emptyScreen.clipsToBounds = true
        emptyScreen.alpha = cards.isEmpty ? 1.0 : 0.0
        return emptyScreen
    }

    fileprivate func hideEmptyScreen() {
        UIView.animate(withDuration: 0.2) {
            self.emptyScreen.alpha = 0.0
            self.collectionView.alpha = 1.0
        }
    }

    fileprivate func showEmptyScreen() {
        UIView.animate(withDuration: 0.2) {
            self.emptyScreen.alpha = 1.0
            self.collectionView.alpha = 0.0
        }
    }

    @objc fileprivate func addTapped(sender: UIBarButtonItem) {
        showDetails(of: Card(name: ""), mode: .create)
    }

    fileprivate func showDetails(of card: Card, mode: CardDetailsViewController.Mode = .normal) {
        let viewController = CardDetailsViewController(card: card, mode: mode)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDataSource
extension CardsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            reuseIdentifier, for: indexPath) as? CardCell,
            let card = cards[safe: indexPath.row]
            else { return UICollectionViewCell() }
        cell.image = card.front ?? #imageLiteral(resourceName: "background")
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CardsViewController: UICollectionViewDelegate {}

// MARK: - IndexedCellDelegate
extension CardsViewController: IndexedCellDelegate {
    func cellWasTapped(_ cell: IndexedCell) {
        guard let indexPath = cell.indexPath,
            let card = cards[safe: indexPath.row] else { return }
        showDetails(of: card)
    }
}
