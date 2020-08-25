# Display a map:

## Adding a Map
###### 1. Add a view to your view controller in Interface Builder
###### 2. Set the class of this new view to `VLTMapView`, and the module to `VLTMaps`
###### 3. Connect your `VLTMapView` to the swift file for its containing view controller (`<YourViewController>.swift`) via an `@IBOutlet`
###### 4. In `viewDidLoad()`: 
```swift
override func viewDidLoad() {
    /// Configure the map with the initial mode (.day, .night, .satellite), any built-in features that should be hidden, and the initial center for the camera
    let mapConfiguration = MapConfiguration(mode: .day, 
                                            hiddenFeatures: [.traffic], 
                                            cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604))

    /// Load the map using your given API key
    mapView.loadMap(apiKey: <Enter your API Key Here>, configuration: mapConfiguration)
}
```

###### 5. Build and run your project. 

# Map Delegation and Callbacks
#### To improve communication with that state of the map, the following protocol can be adopted: `VLTMapViewDelegate`. This contains several delegate methods that the map will call as it is loading, updating, and being interacted with.
###### Set controller as the delegate for the VLTMapView
```swift
class <YourViewController>: UIViewController, VLTMapViewDelegate {
...

override func viewDidLoad() {
    /// Configure the map with the initial mode (.day, .night, .satellite), any built-in features that should be hidden, and the initial center for the camera
    let mapConfiguration = MapConfiguration(mode: .day, hiddenFeatures: [.traffic], cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604))

    /// Load the map using your given API key
    mapView.loadMap(apiKey: <Enter your API Key Here>, configuration: mapConfiguration)
    
    /// Assign view controller as mapView delegate
    mapView.delegate = self
}
```

### Make use of `VLTMapViewDelegate.didFinishLoadingMap(mapView: VLTMapView)` and `VLTMapViewDelegate.didFailLoadingMap(mapView: VLTMapView, error: VLTError)` to determine when your map has completed loading, or failed to load with a given reason.
### Make use of `VLTMapViewDelegate.tappedOnMap(mapView: VLTMaps.VLTMapView, point: CGPoint, coordinate: CLLocationCoordinate2D)` to determine when and where a user has tapped on the map (not including tapping on VLTMapMarker, VLTMapCircle, VLTMapPolygon, or VLTMapPolyline objects)
### Make use of `VLTMapViewDelegate.tappedOnCallout(mapView: VLTMaps.VLTMapView, shape: VLTMaps.VLTMapShape)` to determine when the callout bubble for a given shape has been tapped on by a user

# Updating the Camera 
### (After Map Loads)
### Updates the camera to view the center of the map, 30˚ from the zenith, 20˚ West of North, and zooms to see an individual neighborhood/borough 
```swift
try mapView.camera.updateCamera(tilt: 30.0,
                                bearing: 20.0,
                                zoom: 16.0,
                                withAnimation: true)
```

### Listen for updates to the camera when the user pans, zooms, or otherwise changes the viewport of the map using the `VLTMapViewDelegate.didUpdateCameraPosition(mapView: VLTMaps.VLTMapView)` method


# Updating the Map Mode
### (After Map Loads)
### Updates the map to display Day mode (light), Night mode (dark), or Satellite mode (detail)
```swift
/// Set mode to .day, .night, or .satellite
try mapView.setMode(mode: .day)
```


# Display User Location
### In `VLTMapViewDelegate.didFinishLoadingMap(mapView: VLTMapView)`
```swift
func didFinishLoadingMap(mapView: VLTMapView) {
    mapView.showsUserLocation = true
}
```
### Errors that occur when attempting to display a user's location will be passed via the `VLTMapViewDelegate.failedToShowUserLocation(mapView: VLTMaps.VLTMapView, error: VLTMaps.VLTError)` method

# Displaying and Hiding Traffic Flow
## Displaying at load time
### In `viewDidLoad`
```swift
/// In your map configuration, leave 'hiddenFeatures' as an empty array to show traffic at load time
let mapConfiguration = MapConfiguration(mode: .day, 
                                        hiddenFeatures: [], 
                                        cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604))

/// Load the map using your given API key
mapView.loadMap(apiKey: <Enter your API Key Here>, 
                configuration: mapConfiguration)

```

## Hiding at load time
### In `viewDidLoad`
```swift
/// In your map configuration, include .traffic in 'hiddenFeatures' to hide traffic at load time
let mapConfiguration = MapConfiguration(mode: .day, 
                                        hiddenFeatures: [.traffic], 
                                        cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604))

/// Load the map using your given API key
mapView.loadMap(apiKey: <Enter your API Key Here>, 
                configuration: mapConfiguration)
```

## Displaying after map load
```swift
/// Set the traffic feature to no longer be hidden
try mapView.toggleMapFeatures([.traffic], isHidden: false)
```


## Hiding after map load
```swift
/// Set the traffic feature to be hidden
try mapView.toggleMapFeatures([.traffic], isHidden: true)
```


# Working with Circles on the map
## Add a Circle to the map
### (After map loads)
```swift
/// Create a circle with a title and subtitle that will display a callout when tapped
let circle = VLTMapCircle(coordinate: CLLocationCoordinate2D(latitude: 42.3600, longitude: -71.06137),
                          radius: 100,
                          title: "Circle Title!",
                          subtitle: "Circle Subtitle!",
                          shouldCallout: true,
                          fillColor: .blue,
                          strokeWidth: 4,
                          strokeColor: .cyan)
/// Add the circle to the map
try mapView.add(object: circle1)
```

## Update a Circle that exists on the map
### Each property can be updated on their own or in any combination
```swift
/// Update location of the center of the circle
circle.coordinate = CLLocationCoordinate2D(latitude: 0,
                                           longitude: 15)
/// Update the stroke color of the circle
circle.strokeColor = .black
/// Update the stroke width of the circle
circle.strokeWidth = 10
/// Update the fill color of the circle
circle.fillColor = .green
/// Update the radius of the circle
circle.radius = 200
/// Update the title of the circle with a new one
circle.title = "My new title!"
/// Update the subtitle of the circle with a new one
circle.subtitle = "An updated subtitle!"
/// Update whether or not the circle should display a callout when tapped
circle.shouldCallout = true

/// Notify the map that the circle needs to be updated
try mapView.update(object: circle)
```

## Remove a circle that exists on the map
```swift
/// Remove the existing circle from the map
try mapView.remove(object: circle)
```

## Handle a user tapping on a circle that has been placed on the map using the `VLTMapViewDelegate.tappedOnCircle(mapView: VLTMaps.VLTMapView, circle: VLTMaps.VLTMapCircle, coordinate: CLLocationCoordinate2D)` method


# Working with Markers on the map
## Add a Marker to the map
### (After map loads)
```swift
/// Create a marker instance
let marker = VLTMapMarker(coordinate: CLLocationCoordinate2D(latitude: 42.3637,
                                                             longitude: -71.053604),
                                                             title: "My Marker Title!",
                                                             subtitle: "Marker Subtitle!",
                                                             shouldCallout: true)
/// Add the marker to the map
try mapView.add(object: marker)
```

## Update a Marker that exists on the map
### Each property can be updated on their own or in any combination
```swift
/// Update the image of the marker with a new one
marker.image = customVLTImage
/// Update the title of the marker with a new one
marker.title = "A new title!"
/// Update the subtitle of the marker with a new one
marker.subtitle = "A new subtitle!"
/// Update whether or not the marker should display a callout when tapped
marker.shouldCallout = true

/// Notify the map that the marker needs to be updated
try mapView.update(object: marker)
```

## Remove a marker that exists on the map
```swift
/// Remove the existing marker from the map
try mapView.remove(object: marker)
```

## Handle a user tapping on a marker that has been placed on the map using the `VLTMapViewDelegate.tappedOnMarker(mapView: VLTMaps.VLTMapView, marker: VLTMaps.VLTMapMarker, coordinate: CLLocationCoordinate2D)` method


# Working with Polylines on the map
## Add a Polyline to the map
### (After map loads)
```swift
/// The list of coordinates that the polyline will consist of
let polylineCoordinates = [
    CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604),
    CLLocationCoordinate2D(latitude: 42.362061, longitude: -71.05491),
    CLLocationCoordinate2D(latitude: 42.362554, longitude: -71.055778),
    CLLocationCoordinate2D(latitude: 42.361543, longitude: -71.057602),
    CLLocationCoordinate2D(latitude: 42.35887, longitude: -71.056763),
    CLLocationCoordinate2D(latitude: 42.358851, longitude: -71.05748)
]

/// Create a custom polyline object with a title and subtitle that will display a callout when tapped
let polyline = VLTMapPolyline(coordinates: polylineCoordinates,
                              title: "My Polyline Title!",
                              subtitle: "Polyline Subtitle!",
                              shouldCallout: true,
                              strokeWidth: 5,
                              strokeColor: .red)

/// Add polyline to the map
try mapView.add(object: polyline)
```

## Update a Polyline that exists on the map
### Each property can be updated on their own or in any combination
```swift
/// Create a reduced set of coordinates for the polyline to follow

/// Update the list of coordinates comprising the polyline
polyline.coordinates = newCoordinates

/// Update the stroke color of the polyline
polyline.strokeColor = .green
/// Update the stroke width of the polyline
polyline.strokeWidth = 10
/// Update the title of the polyline with a new one
polyline.title = "A new title!"
/// Update the subtitle of the polyline with a new one
polyline.subtitle = nil
/// Update whether or not the polyline should display a callout when tapped
polyline.shouldCallout = true

/// Notify the map to update the polyline
try mapView.update(object: polyline)
```

## Remove a polyline that exists on the map
```swift
/// Remove the existing polyline from the map
try mapView.remove(object: polyline)
```

## Handle a user tapping on a polyline that has been placed on the map using the `VLTMapViewDelegate.tappedOnPolyline(mapView: VLTMaps.VLTMapView, polyline: VLTMaps.VLTMapPolyline, coordinate: CLLocationCoordinate2D)` method


# Working with Polygons on the map
## Add a Polygon to the map
### (After map loads)
```swift
/// List of coordinates that the polygon will encompass
let polygonCoordinates = [
CLLocationCoordinate2D(latitude: 42.363808, longitude: -71.053601),
CLLocationCoordinate2D(latitude: 42.363667, longitude: -71.053667),
CLLocationCoordinate2D(latitude: 42.363688, longitude: -71.053727),
CLLocationCoordinate2D(latitude: 42.363716, longitude: -71.053717),
CLLocationCoordinate2D(latitude: 42.363750, longitude: -71.053765),
CLLocationCoordinate2D(latitude: 42.363788, longitude: -71.053742)
]

/// Create a customized VLTMapPolygon object with a title and subtitle that displays a callout when the polygon is tapped on the map
let polygon = VLTMapPolygon(coordinates: polygonCoordinates,
                            title: "My Polygon Title!",
                            subtitle: "And its subtitle!",
                            shouldCallout: true,
                            fillColor: .orange,
                            strokeWidth: 4,
                            strokeColor: .white)

/// Add the polygon to the map
try mapView.add(object: polygon)
```

## Update a Polygon that exists on the map
### Each property can be updated on their own or in any combination
```swift
/// Update the list of coordinates comprising the polygon
polygon.coordinates = newCoordinates

/// Update the stroke color of the polygon
polygon.strokeColor = .random
/// Update the fill color of the polygon
polygon.fillColor = .random
/// Update the title of the polygon with a new one
polygon.title = "An updated title"
/// Update the subtitle of the polygon with a new one
polygon.subtitle = "A new subtitle"
/// Update whether or not the polygon should display a callout when tapped
polygon.shouldCallout = true

/// Notify the map that the polygon needs to be updated
try mapView.update(object: polygon)
```

## Remove a polygon that exists on the map
```swift
/// Remove the existing polygon from the map
try mapView.remove(object: polygon)
```

## Handle a user tapping on a polygon that has been placed on the map using the `VLTMapViewDelegate.tappedOnPolygon(mapView: VLTMaps.VLTMapView, polygon: VLTMaps.VLTMapPolygon, coordinate: CLLocationCoordinate2D)` method


# Working with GeoJSON on the map
## Add a GeoJSON Feature/Feature Collection to the map
### (After map loads)
```swift

/// Get GeoJSON data (using a data string)
let geoJSONString = """{
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "properties": {},
            "geometry": {
                "type": "MultiPolygon",
                "coordinates": [
                    [
                        [[-71.06327176094055, 42.35767579564448],
                        [-71.06552481651306, 42.356997938736434],
                        [-71.06937646865845, 42.35613375967782],
                        [-71.07235908508301, 42.35542020837879],
                        [-71.07068538665771, 42.35202676465739],
                        [-71.06745600700378, 42.352724497021356],
                        [-71.06463432312012, 42.35244699075886],
                        [-71.06413006782532, 42.353850367002394],
                        [-71.06343269348145, 42.355206141409205],
                        [-71.0620379447937, 42.35650242467463],
                        [-71.06327176094055, 42.35767579564448]]
                    ],
                    [
                        [[-71.07729434967041,  42.35006435085651],
                        [-71.07691347599028, 42.34934280148833],
                        [-71.0765916109085, 42.34948552619635],
                        [-71.0760498046875, 42.34961635689398],
                        [-71.0756903886795, 42.349675825302874],
                        [-71.0748964548111, 42.3498899111091],
                        [-71.07525587081909, 42.35062731219375],
                        [-71.07729434967041, 42.35006435085651]]
                    ]
                ]
            }
        },
        {
            "type": "Feature",
            "properties": {},
            "geometry": {
                "type": "MultiPoint",
                "coordinates": [
                    [-71.06389939785004, 42.35547967129649],
                    [-71.06390073895453, 42.35784922277229],
                    [-71.06201648712158, 42.35680964385321],
                    [-71.06174558401106, 42.35739236513674],
                    [-71.05983853340149, 42.35828229299582],
                    [-71.05956226587296, 42.357990937155655],
                    [-71.05840623378754, 42.357521197344184],
                    [-71.05837136507034, 42.356978118248975],
                    [-71.05704367160797, 42.358769865053375],
                    [-71.05744332075119, 42.35869851328125],
                    [-71.05619609355927, 42.360006616230265],
                    [-71.05368286371231, 42.36372564197258],
                    [-71.0544365644455, 42.36628513131905],
                    [-71.05583131313324, 42.36726807434951],
                    [-71.05648040771484, 42.37228956345743],
                    [-71.06079339981079, 42.37633182812836]
                ]
            }
        },
        {
            "type": "Feature",
            "properties": {},
            "geometry": {
                "type": "LineString",
                "coordinates": [
                    [-71.06392621994019, 42.35553120577965],
                    [-71.06390476226807, 42.35794138670829],
                    [-71.06199502944946, 42.3568948721334],
                    [-71.06171607971191, 42.35746570042566],
                    [-71.05982780456543, 42.35836950128394],
                    [-71.05954885482788, 42.35803652353272],
                    [-71.05836868286133, 42.35700586692964],
                    [-71.05841159820557, 42.35760840668854],
                    [-71.0574460029602, 42.35881346887422],
                    [-71.0569953918457, 42.35884518072492],
                    [-71.05615854263306, 42.36012949722928],
                    [-71.05366945266724, 42.363792033451034],
                    [-71.05446338653564, 42.36636043798232],
                    [-71.05579376220703, 42.36739094114689],
                    [-71.05656623840332, 42.3724163835571],
                    [-71.06077194213867, 42.376379382634845]
                ]
            }
        }
    ]
}"""

let geoJSONData = Data(geoJSONString.utf8)

/// -OR- 
/// Get GeoJSON data from a json file
guard let path = Bundle.main.path(forResource: "YourGeoJSONFileName", ofType: ".json"), 
      let geoJSONData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
      // Catch failure here
}

/// Create a style to apply to the geoJSON being rendered on the map
let geoJSONStyle = VLTGeoJSONStyle(polygonFillColor: .cyan,
                                   polygonStrokeColor: .black,
                                   polygonFillOpacity: 0.5,
                                   polylineStrokeWidth: 15,
                                   polylineStrokeColor: .systemPink,
                                   polylineStrokeOpacity: 1,
                                   imageName: VLTMapObjectConstants.Defaults.markerImage.imageName)

do {
    /// Create a VLTMapGeoJSON object to place on the map
    let geoJSONObject = try VLTMapGeoJSON(data: geoJSONData, style: geoJSONStyle)
    /// Register a VLTImage for use with Point objects
    try mapView.register(images: [VLTMapObjectConstants.Defaults.markerImage])
    /// Add the GeoJSON Object to the map
    try mapView.add(object: geoJSON)
} catch {
    /// Handle the error
}

```

## Update a GeoJSON object that exists on the map
### Each property can be updated on their own or in any combination
```swift
/// Create a new VLTImage to be used on the map, if it has not been registered on the map before
let customMarker = VLTImage(image: yourUIImage, imageName: "AnIdentifierForYourImage")

do {
    /// Register a new image with the map if it hasn't been registered before
    try mapView.register(images: [customMarker])
    /// Create a reference to the existing style
    let style = geoJSONObject.style
    /// Update the properties of the existing style
    style.polygonFillColor = .orange
    style.polygonStrokeColor = .purple
    style.polygonFillOpacity = 1.0
    style.polylineStrokeWidth = 10
    style.polylineStrokeColor = .cyan
    style.polylineStrokeOpacity = 0.7
    style.imageName = customMarker.imageName
    
    /// Notify the map that the GeoJSON object needs to be updated
    try mapView.update(object: geoJSON)
} catch {
    /// Handle any errors
}
```

## Remove a GeoJSON object that exists on the map
```swift
/// Remove the existing polygon from the map
try mapView.remove(object: geoJSONObject)
```

## GeoJSON Tips, Tricks, and Notes
### GeoJSON Data support
```swift
/// The VLTMapGeoJSON object can take in individual GeoJSON features, as well as GeoJSON feature collections e.g.:
/// GeoJSON Feature Example:
let geoJSONFeatureString = """
    {
        "type": "Feature",
        "properties": {},
        "geometry": {
            "type": "Polygon",
            "coordinates": [[
                [-71.05633020401001, 42.357386419028494],
                [-71.05616927146912, 42.35660152779957],
                [-71.05596542358397, 42.356070333223755],
                [-71.05566501617432, 42.355705629870634],
                [-71.05497837066649, 42.356062404912514],
                [-71.05633020401001, 42.357386419028494]
            ]]
        }
    }
"""
/// GeoJSON Feature Collection Example:
let geoJSONFeatureCollectionString = """
    {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "properties": {},
                "geometry": {
                    "type": "Polygon",
                    "coordinates": [[
                        [-71.05633020401001, 42.357386419028494],
                        [-71.05616927146912, 42.35660152779957],
                        [-71.05596542358397, 42.356070333223755],
                        [-71.05566501617432, 42.355705629870634],
                        [-71.05497837066649, 42.356062404912514],
                        [-71.05633020401001, 42.357386419028494]
                    ]]
                }
            }
        ]
    }
"""
```

### GeoJSON Styling
```swift
/// The GeoJSONStyle object has all optional parameters, with corresponding names to GeoJSON types that the styling will be applied to. 
/// If the GeoJSON only contains one kind of object (eg, all Polygons), then the style will only need polygon-related properties. Feel free to mix and match the properties that you need:
    /// For Just Polygons/MultiPolygons
    let polygonGeoJSONStyle = VLTGeoJSONStyle(polygonFillColor: .cyan,
                                              polygonStrokeColor: .black,
                                              polygonFillOpacity: 0.5)
    /// For Just Polylines/MultiPolylines
    let polygonGeoJSONStyle = VLTGeoJSONStyle(polylineStrokeWidth: 15,
                                              polylineStrokeColor: .systemPink,
                                              polylineStrokeOpacity: 1)
    /// For Just Points/MultiPoints
    let polygonGeoJSONStyle = VLTGeoJSONStyle(imageName: VLTMapObjectConstants.Defaults.markerImage.imageName)
```

### Registering Images
```swift
/* When creating a VLTMapMarker object and adding it to the map, images are not required to be added to the map manually. 
    However, images do have to be registered with the map manually in order to be displayed for a VLTMapGeoJSON object. 
    When an image should be displayed for Points/MultiPoints, the following process should be used: */
    
    /// Create a VLTImage to be used on the map, if it has not been registered on the map before
    let customMarker = VLTImage(image: yourUIImage, imageName: "AnIdentifierForYourImage")
    
    /// Create a style to apply to the geoJSON being rendered on the map
    let geoJSONStyle = VLTGeoJSONStyle(imageName: customMarker.imageName)
    
    do {
        /// Create a VLTMapGeoJSON object to place on the map
        let geoJSONObject = try VLTMapGeoJSON(data: geoJSONData, style: geoJSONStyle)
        
        /// Register a VLTImage for use with Point objects
        try mapView.register(images: [VLTMapObjectConstants.Defaults.markerImage])
        
        /// Add the GeoJSON Object to the map
        try mapView.add(object: geoJSON)
    } catch {
        /// Handle the error
    }
```
