//
//  MapPinsViewController.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 31.01.2021.
//

import UIKit
import MapKit
import CoreData

class MapPinsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var pins : [Pin] = []
    
    var fetchResultsController: NSFetchedResultsController<Pin>!
    var dataController = DataController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultsController()
        showPins()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch  {
            fatalError()
        }
    }
    
    func showPins() {
        guard (fetchResultsController.fetchedObjects?.count) != nil else {
            return
        }
        for pin in fetchResultsController.fetchedObjects! {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            self.mapView.addAnnotation(annotation)
            self.pins.append(pin)
        }
        
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
        addAnnotation(location: locationOnMap)
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Some Title"
        annotation.subtitle = "Some Subtitle"
        
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = annotation.coordinate.latitude
        newPin.longitude = annotation.coordinate.longitude
        try? dataController.viewContext.save()
        
        pins.append(newPin)
        self.mapView.addAnnotation(annotation)
    }
}

extension MapPinsViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        let pin = self.pins.first(where: { $0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude})
        vc.pin = pin
        navigationController?.pushViewController(vc, animated: true)
    }
}
