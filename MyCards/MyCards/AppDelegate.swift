//
//  AppDelegate.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        configureNavigationBar()
        configureTextField()
        return true
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = .orange
        appearance.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.titleBlue,
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .callout),
        ]
    }

    func configureTextField() {
        let appearance =  UITextField.appearance()
        appearance.textColor = .orange
    }

    private func configureWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let cardsViewController = CardsViewController()
        window.backgroundColor = .white
        window.rootViewController = UINavigationController(rootViewController: cardsViewController)
        window.makeKeyAndVisible()
        self.window = window
    }
}
