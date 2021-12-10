//
//  CoreData+Convenience.swift
//  Diplom
//
//  Created by ryan on 15.11.2021.
//

import CoreData
import UIKit

// MARK: - Saving Contexts

enum ContextSaveContextualInfo: String {
    case updateMovie = "Updating Movie"
    case favoriteMovie = "Favoriting Movie"
    case unfavoriteMovie = "Unfavoriting Movie"
}

extension NSManagedObjectContext {

    private func handleSavingError(_ error: Error, contextualInfo: ContextSaveContextualInfo) {
        print("Context saving error: \(error)")

        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window,
                let viewController = window?.rootViewController else { return }

            let message = "Failed to save the context when \(contextualInfo.rawValue)."

            if let currentAlert = viewController.presentedViewController as? UIAlertController {
                currentAlert.message = (currentAlert.message ?? "") + "\n\n\(message)"
                return
            }

            let alert = UIAlertController(title: "Core Data Saving Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }


    func save(with contextualInfo: ContextSaveContextualInfo) {
        guard hasChanges else { return }

        do {
            try save()
        } catch {
            handleSavingError(error, contextualInfo: contextualInfo)
        }
    }
}

