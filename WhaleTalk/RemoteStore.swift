//
//  RemoteStore.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/30/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation

protocol RemoteStore {
    func signUp(phoneNumber phoneNumber: String, email: String, password: String, success: ()->(), error: (errorMessage: String)->())
}