//
// VLTConstants+VLTMaps.swift
// VLTDemo
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation
import CoreLocation

extension VLTConstants {

    // Constants for the ShapesViewController Class
    class ShapesVCConstants {
        // Coordinates for the VLTPolygon object
        static let polygonCoordinates = [
            CLLocationCoordinate2D(latitude: 42.363808, longitude: -71.053601),
            CLLocationCoordinate2D(latitude: 42.363667, longitude: -71.053667),
            CLLocationCoordinate2D(latitude: 42.363688, longitude: -71.053727),
            CLLocationCoordinate2D(latitude: 42.363716, longitude: -71.053717),
            CLLocationCoordinate2D(latitude: 42.363750, longitude: -71.053765),
            CLLocationCoordinate2D(latitude: 42.363788, longitude: -71.053742)
        ]
        // Coordinates for the VLTPolyline object
        static let polylineCoordinates = [
            CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604),
            CLLocationCoordinate2D(latitude: 42.362061, longitude: -71.05491),
            CLLocationCoordinate2D(latitude: 42.362554, longitude: -71.055778),
            CLLocationCoordinate2D(latitude: 42.361543, longitude: -71.057602),
            CLLocationCoordinate2D(latitude: 42.35887, longitude: -71.056763),
            CLLocationCoordinate2D(latitude: 42.358851, longitude: -71.05748)
        ]
    }

    // Constants for the RelativePositioningViewController Class
    class RelativePositioningVCConstants {
        // Coordinates for objects on layer C
        static let layerCCoordinates = [
            CLLocationCoordinate2DMake(42.364263708203474, -71.06982707977295),
            CLLocationCoordinate2DMake(42.363090460251776, -71.07051908969879),
            CLLocationCoordinate2DMake(42.36282092722214, -71.07068538665771),
            CLLocationCoordinate2DMake(42.3625513930362, -71.07082486152649),
            CLLocationCoordinate2DMake(42.36169521795214, -71.0705754160881),
            CLLocationCoordinate2DMake(42.36139793220805, -71.07036888599396),
            CLLocationCoordinate2DMake(42.36100154902786, -71.06975197792053),
            CLLocationCoordinate2DMake(42.36106497050473, -71.06689810752869),
            CLLocationCoordinate2DMake(42.36366123226228, -71.06705635786057),
            CLLocationCoordinate2DMake(42.3638633794392, -71.06728434562683),
            CLLocationCoordinate2DMake(42.36390697972543, -71.06780469417572),
            CLLocationCoordinate2DMake(42.363934725346354, -71.06835186481476),
            CLLocationCoordinate2DMake(42.364263708203474, -71.06982707977295)
        ]
        // Coordinates for objects on layer D
        static let layerDCoordinates = [
            CLLocationCoordinate2DMake(42.36111253657037, -71.07235908508301),
            CLLocationCoordinate2DMake(42.36047831940107, -71.07205867767333),
            CLLocationCoordinate2DMake(42.35997094105651, -71.0720157623291),
            CLLocationCoordinate2DMake(42.35879761294287, -71.0722303390503),
            CLLocationCoordinate2DMake(42.35863905340927, -71.07175827026367),
            CLLocationCoordinate2DMake(42.357529125471395, -71.07197284698486),
            CLLocationCoordinate2DMake(42.355943480123585, -71.07132911682129),
            CLLocationCoordinate2DMake(42.35153517584081, -71.06909751892088),
            CLLocationCoordinate2DMake(42.351630322363434, -71.0685396194458),
            CLLocationCoordinate2DMake(42.35550742063882, -71.06318593025208),
            CLLocationCoordinate2DMake(42.356807661798804, -71.06179118156433),
            CLLocationCoordinate2DMake(42.35789381824207, -71.0606861114502),
            CLLocationCoordinate2DMake(42.358559773492416, -71.06016039848328),
            CLLocationCoordinate2DMake(42.35893238823185, -71.05992436408997),
            CLLocationCoordinate2DMake(42.35951112589285, -71.05993509292603),
            CLLocationCoordinate2DMake(42.35997094105651, -71.06016039848328),
            CLLocationCoordinate2DMake(42.360367330738285, -71.06050372123718),
            CLLocationCoordinate2DMake(42.3607399347591, -71.06107234954834),
            CLLocationCoordinate2DMake(42.361366221645646, -71.06275677680969),
            CLLocationCoordinate2DMake(42.36135036635846, -71.06391549110413),
            CLLocationCoordinate2DMake(42.36111253657037, -71.07235908508301)
        ]
    }
}
