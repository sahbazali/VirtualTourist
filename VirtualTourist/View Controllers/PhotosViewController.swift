//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 7.02.2021.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotosFoundLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController = DataController.shared
   
    private var blockOperations: [BlockOperation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setPin(pin)
        setupPhotos(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            fetchPhotosFromAPI(pin)
        }
    }
    
    private func setPin(_ pin: Pin) {
        let location = CLLocationCoordinate2D(latitude: pin.latitude,longitude: pin.longitude)
        let bound = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center: location, span: bound)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        self.mapView.addAnnotation(annotation)
    }
    
    private func setupPhotos(_ pin: Pin) {
        let fr: NSFetchRequest<Photo> = Photo.fetchRequest()
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    private func fetchPhotosFromAPI(_ pin: Pin) {
        let lat = pin.latitude
        let lon = pin.longitude
        DispatchQueue.main.async {
            self.noPhotosFoundLabel.isHidden = true
        }
        self.loadingIndicator.startAnimating()
        FlickrClient.sharedinstance().searchByLatLon(latitude: lat , longitude: lon) { (result) in
            self.loadingIndicator.stopAnimating()
            switch result {
            case .success(let response):
                if response.photos.photo.count == 0 {
                    DispatchQueue.main.async {
                        self.noPhotosFoundLabel.isHidden = false
                    }
                }
                else {
                    self.storePhotos(response.photos.photo, forPin: pin)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    private func storePhotos(_ photos: [PhotoModel], forPin: Pin) {
        for photo in photos {
            if let url = photo.url {
                let managedObject = Photo(context: DataController.shared.viewContext)
                managedObject.url = url
                managedObject.pin = forPin
                try? DataController.shared.viewContext.save()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
        }
    }
    
    @IBAction func newCollectionButtonClicked(_ sender: Any) {
        for photos in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photos)
        }
        try? dataController.viewContext.save()
        fetchPhotosFromAPI(pin!)
    }
}

extension PhotosViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        let op: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.insertItems(at: [newIndexPath]) }
        case .delete:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.deleteItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.moveItem(at: indexPath, to: newIndexPath) }
        case .update:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.reloadItems(at: [indexPath]) }
        }

        blockOperations.append(op)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
}


extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let PhotoCollectionViewCell = cell as! PhotoCollectionViewCell
        PhotoCollectionViewCell.imageUrl = photo.url!
        loadImage(using: PhotoCollectionViewCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    private func loadImage(using cell: PhotoCollectionViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: imageData)
        } else {
            if let url = URL(string: photo.url!) {
                cell.activityIndicator.startAnimating()
                FlickrClient.sharedinstance().getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async{
                        if let currentCell = collectionView.cellForItem(at: index) as? PhotoCollectionViewCell {
                            if currentCell.imageUrl == photo.url! {
                                currentCell.imageView.image = UIImage(data: data)
                                cell.activityIndicator.stopAnimating()
                            }
                        }
                    }
                    try? self.dataController.viewContext.save()
                    }
                }
            }
        }
}
