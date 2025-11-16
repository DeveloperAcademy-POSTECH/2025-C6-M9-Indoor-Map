//
//  LabelAnnotationView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import MapKit

class LabelAnnotationView: MKAnnotationView {
    
    var label: UILabel
    var point: UIView
    
    override var annotation: MKAnnotation? {
        didSet {
            if let title = annotation?.title {
                label.text = title
            } else {
                label.text = nil
            }
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        label = UILabel(frame: .zero)
        point = UIView(frame: .zero)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let radius: CGFloat = 5.0
        point.layer.cornerRadius = radius
        point.layer.borderWidth = 1.0
        point.layer.borderColor = UIColor(named: "AnnotationBorder")?.cgColor
        self.addSubview(point)

        point.translatesAutoresizingMaskIntoConstraints = false
        point.widthAnchor.constraint(equalToConstant: radius * 2).isActive = true
        point.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
        point.topAnchor.constraint(equalTo: topAnchor).isActive = true
        point.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        point.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true

        centerOffset = CGPoint(x: 0, y: label.font.lineHeight / 2 )
        calloutOffset = CGPoint(x: 0, y: -radius)
        canShowCallout = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var backgroundColor: UIColor? {
        get {
            return point.backgroundColor
        }
        set {
            point.backgroundColor = newValue
        }
    }
}
