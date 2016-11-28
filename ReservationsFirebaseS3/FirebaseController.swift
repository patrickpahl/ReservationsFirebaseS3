//
//  FirebaseController.swift
//  ReservationsFirebaseS3
//
//  Created by Patrick Pahl on 11/27/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseController {
    
    static let reservationsReference = FIRDatabase.database().reference(withPath: Reservation.key)
    static let reference = FIRDatabase.database().reference()
    static let userReference = FIRDatabase.database().reference(withPath: "user")
    static let rulesReference = FirebaseController.reference.child("rules")
    
    static func fetchMaxFutureReservationsPerUserRule(completion: @escaping (_ maxReservationRule: Int) -> Void) {
        rulesReference.child("max_future_reservations_per_user").observeSingleEvent(of: .value, with: { data in
            guard let maxFutureReservations = data.value as? Int else {
                completion(0)
                return
            }
            completion(maxFutureReservations)
        })
    }
    
    static func fetchMaxTicketsAvailableRule(completion: @escaping (_ maxTicketsAvailable: Int) -> Void) {
        
        rulesReference.child("max_tickets_available").observeSingleEvent(of: .value, with: { data in
            guard let maxNumberOfTicketsAvailablePerDay = data.value as? Int else {
                completion(0)
                return
            }
        completion(maxNumberOfTicketsAvailablePerDay)
        })
    }
    
}

protocol FirebaseType {
    var endpoint: String { get }
    var identifier: String? { get set }
    var dictionaryCopy: [String: Any] { get }
    
    init?(identifier: String, dictionary: [String: Any])
    
    mutating func save()
    func delete()
}

extension FirebaseType {
    
    mutating func save() {
        var newEndpoint = FirebaseController.reference.child(endpoint)
        if let identifier = identifier {
            newEndpoint = newEndpoint.child(identifier)
        } else {
            newEndpoint = newEndpoint.childByAutoId()
            identifier = newEndpoint.key
        }
        newEndpoint.updateChildValues(dictionaryCopy)
    }
    
    func delete() {
        guard let identifier = identifier else { return }
        
        FirebaseController.reference.child(endpoint).child(identifier).removeValue()
    }
}


