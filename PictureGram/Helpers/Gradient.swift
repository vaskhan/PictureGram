//
//  GradientLayer.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.12.2024.
//

import UIKit

final class Gradient {
    
    static func addGradientBackground(to label: UILabel) {
        label.layoutIfNeeded() // Обновляем размеры метки перед созданием градиента
        
        // Удаляем предыдущие градиентные слои, если они есть
        label.layer.sublayers?.removeAll(where: { $0.name == "GradientLayer" })
        
        // Создаём градиентный слой
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "GradientLayer" // Название слоя для идентификации
        gradientLayer.frame = label.bounds
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Добавляем слой под текстом
        label.layer.insertSublayer(gradientLayer, at: 0)
    }
}

