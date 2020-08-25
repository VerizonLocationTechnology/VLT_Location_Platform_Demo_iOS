//
//  VLTLiterals+VLTMaps.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation

/// String literals to be used throughout the app
extension VLTLiterals {
    /// String literals for FeatureListViewController
    class FeatureListVCLiterals {
        /// Title for FeatureListViewController
        static let title = "Home"
    }
    
    /// String literals for CameraViewController
    class CameraVCLiterals {
        /// Title for CameraViewController
        static let title = VLTLiterals.DemoFeatureLiterals.cameraTitle
        
        /// Map load error message
        static let mapLoadErrorMessage = "Could not load map"
        /// Camera update error message
        static let cameraUpdateErrorMessage = "Could not update camera"
    }
    
    /// String literals for CameraMetricsViewController
    class CameraMetricsVCLiterals {
        /// Title for CameraMetricsViewController
        static let title = "Metrics"
    }
    
    /// String literals for ModesViewController
    class ModesVCLiterals {
        /// Title for ModesViewController
        static let title = "Modes"
        
        /// Mode Update error message
        static let modeUpdateErrorMessage = "Could not update map mode"
    }
    
    /// String literals for UserLocationViewController
    class UserLocationVCLiterals {
        /// Title for UserLocationViewController
        static let title = VLTLiterals.DemoFeatureLiterals.userLocationTitle
        
        /// Map load error message
        static let mapLoadErrorMessage = "Could not load map"
        /// Camera update error message
        static let cameraUpdateErrorMessage = "Could not update camera"
        /// Location update error message
        static let locationUpdateErrorMessage = "Could not show user location"
        
        /// Horizontal accuracy abbreviation
        static let horizonalAccuracyAbbreviation = "HA"
        /// Vertical accuracy abbreviation
        static let verticalAccuracyAbbreviation = "VA"
    }
    
    /// String literals for ShapesViewController
    class ShapesVCLiterals {
        // Title for ShapesViewController
        static let titleForShapes = VLTLiterals.DemoFeatureLiterals.shapesTitle
        static let titleForListeners = VLTLiterals.DemoFeatureLiterals.listenersTitle
        
        // Shape title and subtitle updated literals
        static let shapeTitle = "Title"
        static let shapeSubtitle = "Subtitle"
        static let shapeTitleUpdated = "Title - Updated"
        static let shapeSubtitleUpdated = "Subtitle - Updated"
        private static let couldNotAdd = "Could not add"
        private static let failedToUpdate = "Failed to update"
        private static let couldNotRemove = "Could not remove"
        
        // MARK: - Marker Texts
        // Marker titles
        static let markerText = "Marker"
        static let markerPlural = "markers"
        static let marker1Title = "\(markerText) 1"
        static let marker2Title = "\(markerText) 2"
        static let marker3Title = "\(markerText) 3"
        static let marker5Title = "\(markerText) 5"
        // Marker subtitles
        static let marker1Subtitle = "\(markerText) 1 \(shapeSubtitle)"
        static let marker2Subtitle = "\(markerText) 2 \(shapeSubtitle)"
        static let marker5Subtitle = "\(markerText) 5 \(shapeSubtitle)"
        // Marker errors
        static let addMarkerErrorMessage = "\(couldNotAdd) \(markerPlural)"
        static let updateMarkerErrorMessage = "\(failedToUpdate) \(markerPlural)"
        static let removeMarkerErrorMessage = "\(couldNotRemove) \(markerPlural)"
        
        // MARK: - Circle Texts
        // Circle titles
        static let circleText = "Circle"
        static let circlePlural = "circles"
        static let circle1Title = "\(circleText) 1"
        // Circle subtitles
        static let circle1Subtitle = "\(circleText) 1 \(shapeSubtitle)"
        // Circle errors
        static let addCircleErrorMessage = "\(couldNotAdd) \(circlePlural)"
        static let updateCircleErrorMessage = "\(failedToUpdate) \(circlePlural)"
        static let removeCircleErrorMessage = "\(couldNotRemove) \(circlePlural)"
        
        // MARK: - Polyline Texts
        // Polyline title
        static let polylineText = "Polyline"
        static let polylineTitle = "\(polylineText) \(shapeTitle)"
        // Polyline subtitle
        static let polylineSubtitle = "\(polylineText) \(shapeSubtitle)"
        // Polyline errors
        static let addPolylineErrorMessage = "\(couldNotAdd) \(polylineText)"
        static let updatePolylineErrorMessage = "\(failedToUpdate) \(polylineText)"
        static let removePolylineErrorMessage = "\(couldNotRemove) \(polylineText)"
        
        // MARK: - Polygon Texts
        // Polygon title
        static let polygonText = "Polygon"
        static let polygonTitle = "\(polygonText) \(shapeTitle)"
        // Polygon subtitle
        static let polygonSubtitle = "\(polygonText) \(shapeSubtitle)"
        // Polygon errors
        static let addPolygonErrorMessage = "\(couldNotAdd) \(polygonText)"
        static let updatePolygonErrorMessage = "\(failedToUpdate) \(polygonText)"
        static let removePolygonErrorMessage = "\(couldNotRemove) \(polygonText)"
        
        // MARK: - Traffic Texts
        static let updateTrafficErrorMessage = "\(failedToUpdate) traffic visibility"
        
        // MARK: - VLTMapViewDelegate Texts
        static let tappedOn = "You tapped on"
        static let tappedOnMap = "\(tappedOn) the map!"
        static let tappedOnMarker = "\(tappedOn) a \(markerText)!"
        static let tappedOnCircle = "\(tappedOn) a \(circleText)!"
        static let tappedOnPolyline = "\(tappedOn) a \(polylineText)!"
        static let tappedOnPolygon = "\(tappedOn) a \(polygonText)!"
        static let tappedOnCallout = "\(tappedOn) a shape callout!"
        
        // Delegate Errors
        static let updateCameraError = "\(failedToUpdate) camera"
        static let loadMapError = "Failed to load map"
    }
    
    /// String literals for GeoJSONViewController
    class GeoJSONVCLiterals {
        // Title for GeoJSONViewController
        static let title = VLTLiterals.DemoFeatureLiterals.geoJsonTitle
        
        // Shape title and subtitle updated literals
        private static let couldNotAdd = "Could not add"
        private static let failedToUpdate = "Failed to update"
        private static let couldNotRemove = "Could not remove"
        
        // MARK: - Marker Texts
        // Marker GeoJSON Text
        static let markerText = "Point GeoJSON"
        // Marker GeoJSON Errors
        static let addMarkerErrorMessage = "\(couldNotAdd) \(markerText)"
        static let updateMarkerErrorMessage = "\(failedToUpdate) \(markerText)"
        static let removeMarkerErrorMessage = "\(couldNotRemove) \(markerText)"
        
        // MARK: - Polyline Texts
        // Polyline GeoJSON Text
        static let polylineText = "Polyline GeoJSON"
        // Polyline GeoJSON Errors
        static let addPolylineErrorMessage = "\(couldNotAdd) \(polylineText)"
        static let updatePolylineErrorMessage = "\(failedToUpdate) \(polylineText)"
        static let removePolylineErrorMessage = "\(couldNotRemove) \(polylineText)"
        
        // MARK: - Polygon Texts
        // Polygon GeoJSON Text
        static let polygonText = "Polygon GeoJSON"
        // Mixed GeoJSON Errors
        static let addPolygonErrorMessage = "\(couldNotAdd) \(polygonText)"
        static let updatePolygonErrorMessage = "\(failedToUpdate) \(polygonText)"
        static let removePolygonErrorMessage = "\(couldNotRemove) \(polygonText)"
        
        // MARK: - Mixed Texts
        // Mixed GeoJSON Text
        static let mixedText = "Mixed GeoJSON"
        // Mixed GeoJSON Errors
        static let addMixedErrorMessage = "\(couldNotAdd) \(mixedText)"
        static let updateMixedErrorMessage = "\(failedToUpdate) \(mixedText)"
        static let removeMixedErrorMessage = "\(couldNotRemove) \(mixedText)"
        
        // MARK: - VLTMapViewDelegate Texts
        static let tappedOn = "You tapped on"
        static let tappedOnMap = "\(tappedOn) the map!"
        // Delegate Errors
        static let updateCameraError = "\(failedToUpdate) camera"
        static let loadMapError = "Failed to load map"
    }
    
    /// String literals for VisibleFeaturesViewController
    class VisibleFeaturesVCLiterals {
        /// Title for VisibleFeaturesViewController
        static let title = "Visible Features"
        
        /// Cell Reuse Identifier for cells in the list
        static let cellReuseIdentifier = "ShapeMarkerOptionsCellReuseIdentifier"
        
    }
    
    /// String literals for DemoFeatures enum
    class DemoFeatureLiterals {
        /// Demo Feature Titles
        static let welcomeTitle = "Welcome."
        static let cameraTitle = "Camera"
        static let modesTitle = "Modes"
        static let userLocationTitle = "User Location"
        static let shapesTitle = "Shapes"
        static let geoJsonTitle = "GeoJSON"
        static let listenersTitle = "Listeners"
        
        /// Demo Feature Content
        static let welcomeContent = "Welcome to the VLT Demo Application, view our supported functionality below."
        static let cameraContent = "Use camera controls to programmatically set, manage and limit user zoom, tilt and bearing."
        static let modesContent = "Verizon map modes show fresh day-time map tiles in multiple styles(e.g. - day, night, satellite, etc.) with additional options including terrain or traffic flow."
        static let userLocationContent = "Display your real-time location, anywhere in the world."
        static let shapesContent = "Place points, lines and shapes to customize maps."
        static let geoJsonContent = "Use GeoJSON feature collections to create and style points, lines and shapes on your map."
        static let listenersContent = "Understand user interactions with the map, using our gesturelisteners and callbacks."
        
        /// Storyboard Segues
        static let cameraSegue = "FeatureListToCameraSegue"
        static let modesSegue = "FeatureListToModesSegue"
        static let userLocationSegue = "FeatureListToUserLocationSegue"
        static let shapesSegue = "FeatureListToShapesSegue"
        static let geoJsonSegue = "FeatureListToGeoJsonSegue"
        static let listenersSegue = "FeatureListToShapesSegue_Listener"
    }
    
    /// String literals for alerts and errors
    class AlertLiterals {
        static let errorTitle = "Error!"
        static let errorActionTitle = "Okay"
        static let alertTitle = "Alert!"
        static let alertActionTitle = "Got it!"
    }
    
    /// String literals for app asset names
    class AssetNameLiterals {
        /// API Key location in plist file
        static let apiKeyLocation = "VLTApiKey"
        
        /// Left Chevron system image name
        static let leftChevronImage = "chevron.left"
        
        /// Custom destination image asset name
        static let customDestinationImage = "CustomDestinationImage"
        
        /// Custom Marker image asset name
        static let customMarkerImage = "CustomMarker"
        
        /// Primary color asset name
        static let primaryColor = "Primary"
        
        /// Secondary color asset name
        static let secondaryColor = "Secondary"
    }
}