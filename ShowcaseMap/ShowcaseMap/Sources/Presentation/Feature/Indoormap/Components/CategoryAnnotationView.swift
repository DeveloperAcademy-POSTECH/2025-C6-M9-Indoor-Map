//
//  CategoryAnnotationView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import MapKit
import UIKit

class CategoryAnnotationView: MKAnnotationView {
    private let markerSize: CGFloat = 20
    private let markerView = UIView()
    private let iconImageView = UIImageView()

    override var annotation: MKAnnotation? {
        didSet {
            updateAppearance()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        markerView.frame = CGRect(x: 0, y: 0, width: markerSize, height: markerSize)
        markerView.layer.cornerRadius = markerSize / 2
        markerView.backgroundColor = .systemBlue
        markerView.layer.borderWidth = 2
        markerView.layer.borderColor = UIColor.white.cgColor

        markerView.layer.shadowColor = UIColor.black.cgColor
        markerView.layer.shadowOpacity = 0.3
        markerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        markerView.layer.shadowRadius = 2

        addSubview(markerView)

        iconImageView.frame = CGRect(x: 4, y: 4, width: markerSize - 8, height: markerSize - 8)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        markerView.addSubview(iconImageView)

        frame = CGRect(x: 0, y: 0, width: markerSize, height: markerSize)

        centerOffset = CGPoint(x: 0, y: 0)
        canShowCallout = true
    }

    private func updateAppearance() {
        guard let annotation = annotation else { return }

        var category: POICategory?
        var iconName: String?

        if let amenity = annotation as? Amenity {
            category = POICategory.from(amenityCategory: amenity.properties.category)
            iconName = category?.iconName
        } else if let unitAnnotation = annotation as? UnitAnnotation {
            category = unitAnnotation.category
            iconName = category?.iconName
        } else if annotation is Occupant {
            markerView.backgroundColor = .systemGray
            iconName = "person.fill"
        }

        if let category = category {
            markerView.backgroundColor = category.color
        }

        if let iconName = iconName {
            let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
            iconImageView.image = UIImage(systemName: iconName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        }
    }
}
