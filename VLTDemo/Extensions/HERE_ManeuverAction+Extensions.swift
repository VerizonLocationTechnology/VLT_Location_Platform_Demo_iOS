//
// HERE_ManeuverAction+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import heresdk
import UIKit

extension ManeuverAction {
    var image: UIImage? {
        switch self {
        case .arrive:
            return UIImage(named: "white_pin")

        case .depart:
            return UIImage(named: "black_pin")

        case .leftUTurn, .rightUTurn:
            return UIImage(systemName: "arrow.uturn.down")

        case .sharpLeftTurn, .leftTurn:
            return UIImage(systemName: "arrow.turn.up.left")

        case .slightLeftTurn, .leftExit, .leftRamp, .leftRoundaboutEnter, .leftFork:
            return UIImage(systemName: "arrow.up.left")

        case .continueOn, .leftRoundaboutPass, .rightRoundaboutPass, .middleFork:
            return UIImage(systemName: "arrow.up")

        case .slightRightTurn, .rightExit, .rightRamp, .rightRoundaboutEnter, .rightFork:
            return UIImage(systemName: "arrow.up.right")

        case .sharpRightTurn, .rightTurn:
            return UIImage(systemName: "arrow.turn.up.right")

        case .ferry:
            return UIImage(systemName: "drop.triangle")

        case .leftRoundaboutExit1, .leftRoundaboutExit2, .leftRoundaboutExit3,
             .leftRoundaboutExit4, .leftRoundaboutExit5, .leftRoundaboutExit6,
             .leftRoundaboutExit7, .leftRoundaboutExit8, .leftRoundaboutExit9,
             .leftRoundaboutExit10, .leftRoundaboutExit11, .leftRoundaboutExit12:
            return UIImage(systemName: "arrow.up.left")
        case .rightRoundaboutExit1, .rightRoundaboutExit2, .rightRoundaboutExit3,
             .rightRoundaboutExit4, .rightRoundaboutExit5, .rightRoundaboutExit6,
             .rightRoundaboutExit7, .rightRoundaboutExit8, .rightRoundaboutExit9,
             .rightRoundaboutExit10, .rightRoundaboutExit11, .rightRoundaboutExit12:
            return UIImage(systemName: "arrow.up.right")

        @unknown default:
            DemoError(file: #file, function: "ManeuverAction.image", line: #line, message: "Unknown ManeuverAction case").print()
            return nil
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func readable(_ street: String?) -> String {
        var maneuver: String = ""
        var predicate: String = ""
        switch self {
        case .depart:
            maneuver = "Start"
            predicate = " at "
        case .arrive:
            maneuver = "Arrive"
            predicate = " at "
        case .leftUTurn:
            maneuver = "Make a U-turn"
            predicate = " at "
        case .sharpLeftTurn:
            maneuver = "Make a hard left turn"
            predicate = " onto "
        case .leftTurn:
            maneuver = "Turn left"
            predicate = " on "
        case .slightLeftTurn:
            maneuver = "Bear left"
            predicate = " onto "
        case .continueOn:
            maneuver = "Continue"
            predicate = " on "
        case .slightRightTurn:
            maneuver = "Bear right"
            predicate = " onto "
        case .rightTurn:
            maneuver = "Turn right"
            predicate = " on "
        case .sharpRightTurn:
            maneuver = "Make a hard right turn"
            predicate = " onto "
        case .rightUTurn:
            maneuver = "Make a right U-turn"
            predicate = " at "
        case .leftExit:
            maneuver = "Take the left exit"
            predicate = " to "
        case .rightExit:
            maneuver = "Take the right exit"
            predicate = " to "
        case .leftRamp:
            maneuver = "Take the left ramp"
            predicate = " onto "
        case .rightRamp:
            maneuver = "Take the right ramp"
            predicate = " onto "
        case .leftFork:
            maneuver = "Take the left fork"
            predicate = " onto "
        case .middleFork:
            maneuver = "Take the middle fork"
            predicate = " onto "
        case .rightFork:
            maneuver = "Take the right fork"
            predicate = " onto "
        case .ferry:
            maneuver = "Take the ferry"
            predicate = " to "
        case .leftRoundaboutEnter:
            maneuver = "Enter the roundabout"
        case .rightRoundaboutEnter:
            maneuver = "Enter the roundabout"
        case .leftRoundaboutPass:
            maneuver = "Pass the roundabout"
        case .rightRoundaboutPass:
            maneuver = "Pass the roundabout"
        case .leftRoundaboutExit1,
             .rightRoundaboutExit1:
            maneuver = "Take the first exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit2,
             .rightRoundaboutExit2:
            maneuver = "Take the second exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit3,
             .rightRoundaboutExit3:
            maneuver = "Take the third exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit4,
             .rightRoundaboutExit4:
            maneuver = "Take the fourth exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit5,
             .rightRoundaboutExit5:
            maneuver = "Take the fifth exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit6,
             .rightRoundaboutExit6:
            maneuver = "Take the sixth exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit7,
             .rightRoundaboutExit7:
            maneuver = "Take the 7th exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit8,
             .rightRoundaboutExit8:
            maneuver = "Take the 8th exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit9,
             .rightRoundaboutExit9:
            maneuver = "Take the 9th exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit10,
             .rightRoundaboutExit10:
            maneuver = "Take the 10th exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit11,
             .rightRoundaboutExit11:
            maneuver = "Take the 11th exit of the roundabout onto "
            predicate = " onto "
        case .leftRoundaboutExit12,
             .rightRoundaboutExit12:
            maneuver = " Take the 12th exit of the roundabout onto "
            predicate = " onto "

        @unknown default:
            DemoError(file: #file, function: "ManeuverAction.readableDirection", line: #line, message: "Unknown ManeuverAction case").print()
            maneuver = "Unknown maneuver "
            predicate = " onto "
        }

        return maneuver + (street == nil ? "" : predicate + " " + street!)
    }
}
