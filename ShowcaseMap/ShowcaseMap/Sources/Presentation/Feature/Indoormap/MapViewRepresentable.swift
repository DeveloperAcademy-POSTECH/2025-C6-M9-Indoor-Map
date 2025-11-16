//
//  MapViewRepresentable.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/16/25.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let overlays: [MKOverlay]
    let annotations: [MKAnnotation]
    let features: [StylableFeature]
    let region: MKMapRect

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        // Hide default map POIs
        mapView.pointOfInterestFilter = .excludingAll

        mapView.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PointAnnotationView")
        mapView.register(LabelAnnotationView.self, forAnnotationViewWithReuseIdentifier: "LabelAnnotationView")
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.features = features

        if !region.isEmpty {
            mapView.setVisibleMapRect(region, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        }

        let existingOverlays = mapView.overlays
        mapView.removeOverlays(existingOverlays)
        mapView.addOverlays(overlays)

        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(features: features)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var features: [StylableFeature]

        init(features: [StylableFeature]) {
            self.features = features
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let shape = overlay as? (MKShape & MKGeoJSONObject),
                  let feature = features.first(where: { $0.geometry.contains(where: { $0 == shape }) }) else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer: MKOverlayPathRenderer
            switch overlay {
            case is MKMultiPolygon:
                renderer = MKMultiPolygonRenderer(overlay: overlay)
            case is MKPolygon:
                renderer = MKPolygonRenderer(overlay: overlay)
            case is MKMultiPolyline:
                renderer = MKMultiPolylineRenderer(overlay: overlay)
            case is MKPolyline:
                renderer = MKPolylineRenderer(overlay: overlay)
            default:
                return MKOverlayRenderer(overlay: overlay)
            }

            feature.configure(overlayRenderer: renderer)

            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            if let stylableFeature = annotation as? StylableFeature {
                if stylableFeature is Occupant {
                    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "LabelAnnotationView", for: annotation)
                    stylableFeature.configure(annotationView: annotationView)
                    return annotationView
                } else {
                    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PointAnnotationView", for: annotation)
                    stylableFeature.configure(annotationView: annotationView)
                    return annotationView
                }
            }

            return nil
        }
    }
}
