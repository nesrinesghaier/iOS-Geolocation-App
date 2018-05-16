//
//  annotation.swift
//  map 2
//
//  Created by SavoirPro on 12/07/2017.
//  Copyright © 2017 SavoirPro. All rights reserved.
//

import MapKit
class Annotation: NSObject, MKAnnotation{
    var title: String?
    var coordinate: CLLocationCoordinate2D
    init(title:String,coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
