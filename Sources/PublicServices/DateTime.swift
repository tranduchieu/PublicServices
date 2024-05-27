//
//  DateTime.swift
//
//
//  Created by Hieu Tran on 28/05/2024.
//

import Foundation

public func parseDuration(from timeString: String) -> Double {
        let components = timeString.split(separator: ":").map { Double($0) }
        
        guard components.count > 0 else {
            return 0.0
        }
        
        // Initialize variables for hours, minutes, and seconds
        var hours = 0.0
        var minutes = 0.0
        var seconds = 0.0
        
        // Determine which components exist based on the count
        switch components.count {
        case 2:
            // Format MM:SS
            minutes = components[0] ?? 0.0
            seconds = components[1] ?? 0.0
        case 3:
            // Format H:MM:SS
            hours = components[0] ?? 0.0
            minutes = components[1] ?? 0.0
            seconds = components[2] ?? 0.0
        default:
            return 0.0
        }
        
        // Convert to total seconds
        return (hours * 3600) + (minutes * 60) + seconds
    }
