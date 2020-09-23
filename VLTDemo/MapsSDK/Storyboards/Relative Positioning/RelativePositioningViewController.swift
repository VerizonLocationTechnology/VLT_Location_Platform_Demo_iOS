//
// RelativePositioningViewController.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit
import CoreLocation
import VLTMaps

class RelativePositioningViewController: UIViewController, VLTMapViewDelegate, RelativePositioningTableDelegate {

    /// Enum representing the layers of objects that we are showing on the map
    enum LayerNames: String {
        case layerA = "Layer A", layerB = "Layer B", layerC = "Layer C", layerD = "Layer D"
    }

    // MARK: - Private Members
    private typealias literals = VLTLiterals.RelativePositioningVCLiterals
    private typealias constants = VLTConstants.RelativePositioningVCConstants
    /// Southwest corner of the area to be displayed on the map at load time
    private let initialSouthwestCoordinate = CLLocationCoordinate2DMake(42.34753651301409, -71.0745009899108)
    /// Northeast corner of the area to be displayed on the map at load time
    private let initialNortheastCoordinate = CLLocationCoordinate2DMake(42.367073230899706, -71.05851266383391)
    /// Padding around the initial area defined by the southwest and northeast coordinates. Positive values zoom the camera away from the bounding box, while negative values zoom the camera in closer to the bounding box
    private let configurationPadding = UIEdgeInsets(top: -160, left: -160, bottom: -160, right: -160)

    /// Coordinates for the objects on Layer C
    private static let layerCCoordinates = constants.layerCCoordinates
    /// Coordinates for the objects on Layer D
    private static let layerDCoordinates = constants.layerDCoordinates

    // MARK: - Internal Members
    typealias Layer = [VLTMapObject]

    /// Data for the VLTMapGeoJSON object on Layer A
    let geoJSONAData = Data.from(fileNamed: "GeoJSON-SectionA", withExtension: ".json")
    /// Data for the VLTMapGeoJSON object on Layer B
    let geoJSONBData = Data.from(fileNamed: "GeoJSON-SectionB", withExtension: ".json")

    /// Layers of objects being displayed on the map
    var layerA = Layer()
    var layerB = Layer()
    var layerC = Layer()
    var layerD = Layer()
    /// Order of layers displayed on the map
    var layerOrder: [LayerNames] = [
        .layerA,
        .layerB,
        .layerC,
        .layerD
    ]

    // MARK: - IBOutlets
    /// VLTMapView where objects will be displayed
    @IBOutlet weak var mapView: VLTMapView!

    // MARK: - Page Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of view controller
        self.title = literals.title

        /// Retrieve the device's current user interface style
        let interfaceStyle = traitCollection.userInterfaceStyle

        /// Retrieve the map mode that reflects the UI style of the current device
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: interfaceStyle)

        /// Configure the map with the initial mode, any built-in features that should be hidden, and the Southwest and Northeast bounds and padding of the initial camera view of the map
        let mapConfiguration = MapConfiguration(mode: mode,
                                                southwestCoordinate: initialSouthwestCoordinate,
                                                northeastCoordinate: initialNortheastCoordinate,
                                                boundaryPadding: configurationPadding)

        /// Set the map's delegate
        mapView.delegate = self
        /// Initialize Objects for the map
        initializeLayers()

        /// Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let listController = segue.destination as? RelativePositioningTableVC {
            listController.layers = layerOrder
            listController.delegate = self
        }
    }

    // MARK: Internal Methods
    func initializeLayers() {
        // Fill Layer A
        // Generate a VLTGeoJSONStyle object describing the properties of the GeoJSON to be displayed on the map
        let geoJSONAStyle = VLTGeoJSONStyle(polygonFillColor: .from(hexString: "#ff00f7"),
                                            polygonStrokeColor: .from(hexString: "#7e0170"),
                                            polygonFillOpacity: 0.50,
                                            polylineStrokeWidth: 2,
                                            polylineStrokeColor: .from(hexString: "#7e0170"))
        // Generate a VLTMapGeoJSON object to be displayed on the map, with its style properties and data
        guard let geoJSONAData = geoJSONAData, let geoJSONA = try? VLTMapGeoJSON(data: geoJSONAData, style: geoJSONAStyle) else {
            showError(withMessage: "\(literals.createGeoJSONErrorMessage)")
            return
        }
        // Add GeoJSON object to 'Layer A'
        layerA = [geoJSONA]

        // Fill Layer B
        // Generate a VLTGeoJSONStyle object describing the properties of the GeoJSON to be displayed on the map
        let geoJSONBStyle = VLTGeoJSONStyle(polygonFillColor: .from(hexString: "#ffdd00"),
                                            polygonStrokeColor: .from(hexString: "#8a7300"),
                                            polygonFillOpacity: 0.50,
                                            polylineStrokeWidth: 2,
                                            polylineStrokeColor: .from(hexString: "#8a7300"))
        // Generate a VLTMapGeoJSON object to be displayed on the map, with its style properties and data
        guard let geoJSONBData = geoJSONBData, let geoJSONB = try? VLTMapGeoJSON(data: geoJSONBData, style: geoJSONBStyle) else {
            showError(withMessage: "\(literals.createGeoJSONErrorMessage)")
            return
        }
        // Add GeoJSON object to 'Layer B'
        layerB = [geoJSONB]

        // Fill Layer C
        // Generate a VLTMapPolygon object with its coordinates and style properties
        let polygonC = VLTMapPolygon(coordinates: Self.layerCCoordinates,
                                     fillColor: UIColor.from(hexString: "#00d9ff").withAlphaComponent(0.50),
                                     strokeColor: .from(hexString: "#025b79"))
        // Generate a VLTMapPolyline object with its coordinates and style properties
        let polylineC = VLTMapPolyline(coordinates: Self.layerCCoordinates,
                                       strokeWidth: 2,
                                       strokeColor: .from(hexString: "#025b79"))
        // Add new polygon and polyline to 'Layer C'
        layerC = [polygonC, polylineC]

        // Fill Layer D
        // Generate a VLTMapPolygon object with its coordinates and style properties
        let polygonD = VLTMapPolygon(coordinates: Self.layerDCoordinates,
                                     fillColor: UIColor.from(hexString: "#51ff00").withAlphaComponent(0.50),
                                     strokeColor: .from(hexString: "#3e8901"))
        // Generate a VLTMapPolyline object with its coordinates and style properties
        let polylineD = VLTMapPolyline(coordinates: Self.layerDCoordinates,
                                       strokeWidth: 2,
                                       strokeColor: .from(hexString: "#3e8901"))
        // Add new polygon and polyline to 'Layer D'
        layerD = [polygonD, polylineD]
    }

    func updateLayers() {
        // Verify that layerOrder contains 4 objects
        guard layerOrder.count == 4 else {
            showError(withMessage: literals.layersOutOfOrderErrorMessage)
            return
        }

        // Retrieve the ordered list of layers that should be added to the map
        let layers = getLayerList()
        // Retrieve references to some of the objects that we will need to reference when adding objects on the map
        guard let layer0ReferenceObject = layers[0].first,
            let layer3ReferenceObject = layers[3].first else {
                showError(withMessage: literals.layersOutOfOrderErrorMessage)
                return
        }
        // Remove all existing objects from the map. Since we don't know specifically which layers are moving, we are just removing all of them, and then will add them all in freshly
        clearMap()

        // Add objects to Map
        do {
            // Add top layer to the map for reference
            try mapView.add(objects: layers[0])
            // Add second layer below a top-layer reference object
            try mapView.add(objects: layers[1], below: layer0ReferenceObject)
            // Add bottom layer to the bottom of the layer stack
            try mapView.add(objectsToBottom: layers[3])
            // Add final layer above one of the bottom layer objects
            try mapView.add(objects: layers[2], above: layer3ReferenceObject)
        } catch {
            showError(withMessage: "\(literals.addObjectsErrorMessage): \(error)")
        }
    }

    // MARK: Helpers
    /// Returns the list of Layer objects in the corresponding order of the layerOrder object
    func getLayerList() -> [Layer] {
        var layers = [Layer]()
        layerOrder.forEach({
            switch $0 {
            case .layerA:
                layers.append(layerA)
            case .layerB:
                layers.append(layerB)
            case .layerC:
                layers.append(layerC)
            case .layerD:
                layers.append(layerD)
            }
        })
        return layers
    }

    /// Removes all objects from the map
    func clearMap() {
        if !mapView.objects.isEmpty {
            let objects = [layerA, layerB, layerC, layerD].flatMap { $0 }
            do {
                try mapView.remove(objects: objects)
            } catch {
                showError(withMessage: "\(literals.removeObjectsErrorMessage): \(error)")
            }
        }
    }
}

// MARK: VLTMapViewDelegate Conformance
extension RelativePositioningViewController {
    func didFinishLoadingMap(mapView: VLTMapView) {
        // Add Layers to the map
        updateLayers()
    }

    func didFailLoadingMap(mapView: VLTMapView, error: Error) {
        showError(withMessage: literals.mapLoadFailedErrorMessage)
    }
}

// MARK: RelativePositioningTableDelegate Conformance
extension RelativePositioningViewController {
    /// Update the layers on the map to match the order passed in
    func update(with layers: [LayerNames]) {
        self.layerOrder = layers
        updateLayers()
    }
}
