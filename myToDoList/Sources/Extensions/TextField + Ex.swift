//
//  TextField + Ex.swift
//  myToDoList
//
//  Created by 1234 on 17.06.2024.
//

import UIKit

//MARK: - установка отступов в текстфилдах логина и пароля путем вызова функции в настройках самих текстфилдов на контроллере

extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextField {
    func setLeftIcon(_ image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 5, width: 30, height: 30))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame: CGRect(x: 10, y: 0, width: 50, height: 40))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}
