//
// VLTConstants+VLTMaps.swift
// VLTDemo
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import Foundation

extension VLTConstants {
    // Constants for the ShapesViewController Class
    class ShapesVCConstants {
        // Coordinates for the VLTPolygon object
        static let polygonCoordinates = [
            CLLocationCoordinate2D(latitude: 42.363_808, longitude: -71.053_601),
            CLLocationCoordinate2D(latitude: 42.363_667, longitude: -71.053_667),
            CLLocationCoordinate2D(latitude: 42.363_688, longitude: -71.053_727),
            CLLocationCoordinate2D(latitude: 42.363_716, longitude: -71.053_717),
            CLLocationCoordinate2D(latitude: 42.363_750, longitude: -71.053_765),
            CLLocationCoordinate2D(latitude: 42.363_788, longitude: -71.053_742)
        ]
        // Coordinates for the VLTPolyline object
        static let polylineCoordinates = [
            CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053_604),
            CLLocationCoordinate2D(latitude: 42.362_061, longitude: -71.054_91),
            CLLocationCoordinate2D(latitude: 42.362_554, longitude: -71.055_778),
            CLLocationCoordinate2D(latitude: 42.361_543, longitude: -71.057_602),
            CLLocationCoordinate2D(latitude: 42.358_87, longitude: -71.056_763),
            CLLocationCoordinate2D(latitude: 42.358_851, longitude: -71.057_48)
        ]
    }

    // Constants for the RelativePositioningViewController Class
    class RelativePositioningVCConstants {
        // Coordinates for objects on layer C
        static let layerCCoordinates = [
            CLLocationCoordinate2DMake(42.364_263_708_203_474, -71.069_827_079_772_95),
            CLLocationCoordinate2DMake(42.363_090_460_251_776, -71.070_519_089_698_79),
            CLLocationCoordinate2DMake(42.362_820_927_222_14, -71.070_685_386_657_71),
            CLLocationCoordinate2DMake(42.362_551_393_036_2, -71.070_824_861_526_49),
            CLLocationCoordinate2DMake(42.361_695_217_952_14, -71.070_575_416_088_1),
            CLLocationCoordinate2DMake(42.361_397_932_208_05, -71.070_368_885_993_96),
            CLLocationCoordinate2DMake(42.361_001_549_027_86, -71.069_751_977_920_53),
            CLLocationCoordinate2DMake(42.361_064_970_504_73, -71.066_898_107_528_69),
            CLLocationCoordinate2DMake(42.363_661_232_262_28, -71.067_056_357_860_57),
            CLLocationCoordinate2DMake(42.363_863_379_439_2, -71.067_284_345_626_83),
            CLLocationCoordinate2DMake(42.363_906_979_725_43, -71.067_804_694_175_72),
            CLLocationCoordinate2DMake(42.363_934_725_346_354, -71.068_351_864_814_76),
            CLLocationCoordinate2DMake(42.364_263_708_203_474, -71.069_827_079_772_95)
        ]
        // Coordinates for objects on layer D
        static let layerDCoordinates = [
            CLLocationCoordinate2DMake(42.361_112_536_570_37, -71.072_359_085_083_01),
            CLLocationCoordinate2DMake(42.360_478_319_401_07, -71.072_058_677_673_33),
            CLLocationCoordinate2DMake(42.359_970_941_056_51, -71.072_015_762_329_1),
            CLLocationCoordinate2DMake(42.358_797_612_942_87, -71.072_230_339_050_3),
            CLLocationCoordinate2DMake(42.358_639_053_409_27, -71.071_758_270_263_67),
            CLLocationCoordinate2DMake(42.357_529_125_471_395, -71.071_972_846_984_86),
            CLLocationCoordinate2DMake(42.355_943_480_123_585, -71.071_329_116_821_29),
            CLLocationCoordinate2DMake(42.351_535_175_840_81, -71.069_097_518_920_88),
            CLLocationCoordinate2DMake(42.351_630_322_363_434, -71.068_539_619_445_8),
            CLLocationCoordinate2DMake(42.355_507_420_638_82, -71.063_185_930_252_08),
            CLLocationCoordinate2DMake(42.356_807_661_798_804, -71.061_791_181_564_33),
            CLLocationCoordinate2DMake(42.357_893_818_242_07, -71.060_686_111_450_2),
            CLLocationCoordinate2DMake(42.358_559_773_492_416, -71.060_160_398_483_28),
            CLLocationCoordinate2DMake(42.358_932_388_231_85, -71.059_924_364_089_97),
            CLLocationCoordinate2DMake(42.359_511_125_892_85, -71.059_935_092_926_03),
            CLLocationCoordinate2DMake(42.359_970_941_056_51, -71.060_160_398_483_28),
            CLLocationCoordinate2DMake(42.360_367_330_738_285, -71.060_503_721_237_18),
            CLLocationCoordinate2DMake(42.360_739_934_759_1, -71.061_072_349_548_34),
            CLLocationCoordinate2DMake(42.361_366_221_645_646, -71.062_756_776_809_69),
            CLLocationCoordinate2DMake(42.361_350_366_358_46, -71.063_915_491_104_13),
            CLLocationCoordinate2DMake(42.361_112_536_570_37, -71.072_359_085_083_01)
        ]
    }
}
