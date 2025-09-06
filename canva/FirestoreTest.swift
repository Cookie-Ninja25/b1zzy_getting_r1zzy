//
//  FirestoreTest.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

//// 1) Sign in anonymously if needed
//func ensureSignedIn() async throws -> String {
//  if let uid = Auth.auth().currentUser?.uid { return uid }
//  let result = try await Auth.auth().signInAnonymously()
//  return result.user.uid
//}
//
//// 2) Write the user's own document (matches common security rules)
//@MainActor
//func testFirestoreWrite() async {
//  do {
//    let uid = try await ensureSignedIn()
//    let db = Firestore.firestore()
//    try await db.collection("users").document(uid).setData([
//      "displayName": "Swift Test User",
//      "createdAt": FieldValue.serverTimestamp()
//    ])
//    print("Wrote document for uid \(uid)")
//  } catch {
//    print("Write failed: \(error)")
//  }
//}
