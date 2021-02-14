//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Ali Şahbaz on 31.01.2021.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(message: String){
        DispatchQueue.main.async {
            let alertVc = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVc, animated: false, completion: nil)
        }
    }
}
