//
//  ViewController.swift
//  mapkit-joca
//
//  Created by Matheus Silva on 06/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var buttonLocationView: UIView!
    @IBOutlet weak var buttonPinView: UIView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var statusEffectView: UIVisualEffectView!
    
    //MARK:- Variables
    var locationManager = CLLocationManager()
    var authorizedLocation = false
    var currentLocation: MKPointAnnotation?
    var destine: MKPointAnnotation?
    
    //MARK:- Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUp()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, authorizedLocation {
            let position :CGPoint = touch.location(in: view)
            let center = mapView.convert(position, toCoordinateFrom: self.view)
            if pinButton.tag == 0, let currentLocation = currentLocation {
                if let destine = destine {
                    //Remove icon
                    mapView.removeAnnotation(destine)
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Seu destino"
                annotation.subtitle = "mais preciso"
                destine = annotation
                mapView.addAnnotation(annotation)
                
                
                //remove marcacao anterior
                mapView.removeOverlays(mapView.overlays)
                
                //calcula distancia
                setUpStatus(status: "Calculando Rota...")
                
                showSpinner(onView: buttonPinView)
                pressPointButton()
                locationButton.tag = 0
                
                requestDirectionsTo(source: currentLocation.coordinate, destination: annotation.coordinate)
                
            }
        }
    }
    
    //MARK:- Methods
    func setUp() {
        locationManager.delegate = self
        mapView.delegate = self
        pinButton.tag = 1
        locationButton.tag = 1
        setUpStatus()
    }
    
    func setUpStatus(status: String? = nil) {
        if let status = status {
            statusLabel.text = "Status: \(status)"
        } else {
            statusLabel.text = "Status: \(authorizedLocation ? "Ativado" : "Desativado")"
        }
    }
    
    func requestUserAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func feedback() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func pressPointButton() {
        if pinButton.tag == 1 {
            pinButton.alpha = 0.2
            pinButton.tag = 0
        } else {
            pinButton.alpha = 1
            pinButton.tag = 1
        }
    }
    
    func requestDirectionsTo(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            guard let route = unwrappedResponse.routes.first else {
                self.setUpStatus(status: "Error")
                self.removeSpinner()
                return
            }
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                       animated: true)
        }
    }
    
    func removeAll() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    //MARK: - Actions
    @IBAction func getLocation(_ sender: UIButton) {
        if locationButton.tag == 0 { return }
        pinButton.isEnabled = false
        if authorizedLocation {
            if destine != nil, currentLocation != nil {
                removeAll()
            }
            locationManager.requestLocation()
            showSpinner(onView: buttonLocationView)
        } else {
            requestUserAuthorization()
        }
        feedback()
    }
    @IBAction func setPoint(_ sender: UIButton) {
        if pinButton.tag == 0 { return }
        if authorizedLocation {
            pressPointButton()
        } else {
            setUpStatus(status: "Não autorizado")
        }
        feedback()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            authorizedLocation = false
            setUpStatus(status: "Não autorizado")
        } else if status == CLAuthorizationStatus.authorizedWhenInUse {
            authorizedLocation = true
            setUpStatus(status: "Autorizado")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Sua localização"
            annotation.subtitle = "mais precisa"
            currentLocation = annotation
            mapView.addAnnotation(annotation)
            
            self.mapView.setRegion(region, animated: true)
            locationButton.tag = 1
            pinButton.isEnabled = true
            removeSpinner()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        setUpStatus(status: "Error")
        locationButton.tag = 1
        pinButton.isEnabled = true
        removeSpinner()
    }
    
}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = (UIColor(named: "myColorDark") ?? .white) .withAlphaComponent(0.6)
        removeSpinner()
        locationButton.tag = 1
        setUpStatus(status: "Calculado")
        return renderer
    }
}
