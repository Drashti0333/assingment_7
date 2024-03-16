//
//  ViewController.swift
//  assingment7
//
//  Created by user236597 on 3/15/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    let locationManger = CLLocationManager()
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
         
    let locationManager = CLLocationManager()
        var locationOfStarting: CLLocation?
        var startTime: Date?
        var totalDistance: Double = 0
        var tempAverageSpeed: Double = 0
        var tempMaxSpeed: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        setupLocationManager()
        alertLabel.backgroundColor = .green
    }
    
    @IBAction func stopTrip(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        let elapsedTime = Date().timeIntervalSince(startTime ?? Date()) + 1
        calculateMaxAcceleration(interval: elapsedTime)
        alertLabel.backgroundColor = .gray
        warningLabel.backgroundColor = .white
    }
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationOfStarting = locationManager.location
        startTime = Date()
        }
    }
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            render(location)
        }
    }
}
extension ViewController {
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        let speedInKmh = round((location.speed * 3.6) * 100) / 100
        currentSpeedLabel.text = "\(speedInKmh) km/h"
        avgSpeedCalculate(location.speed)
        averageSpeedLabel.text = "\(round((tempAverageSpeed * 3.6) * 100) / 100) km/h"
        maxSpeedCalculate(speedInKmh)
        maxSpeedLabel.text = "\(tempMaxSpeed) km/h"
        
        if speedInKmh > 115 {
            warningLabel.backgroundColor = .red
        } else {
            updateDistance(location: location)
            alertLabel.backgroundColor = .lightGray
        }
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    private func avgSpeedCalculate(_ speed: Double) {
        tempAverageSpeed = (speed + tempAverageSpeed) / 2
    }
    
    private func maxSpeedCalculate(_ speed: Double) {
        tempMaxSpeed = max(tempMaxSpeed, speed)
    }
    
    private func updateDistance(location: CLLocation) {
        if let startingLocation = locationOfStarting {
            totalDistance = (round((location.distance(from: startingLocation) / 1000) * 100) / 100)
            distanceLabel.text = "\(totalDistance) km"
        }
    }
    
    private func calculateMaxAcceleration(interval: Double) {
        let maxAcceleration = round((((tempAverageSpeed / 3.6) / interval) * 100) / 100)
        maxAccelerationLabel.text = "\(maxAcceleration) m/s"
    }
}
