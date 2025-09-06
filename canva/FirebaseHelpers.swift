//
//  FirebaseHelpers.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Signs in anonymously once and returns the UID.
func fh_ensureSignedIn() async throws -> String {
  if let uid = Auth.auth().currentUser?.uid { return uid }
  let result = try await Auth.auth().signInAnonymously()
  return result.user.uid
}

/// Writes one deterministic document: /users/{uid}
@MainActor
func fh_writeTestUser() async {
  do {
    let uid = try await fh_ensureSignedIn()
    let db = Firestore.firestore()
    try await db.collection("users").document(uid).setData([
      "displayName": "Swift Test User",
      "createdAt": FieldValue.serverTimestamp()
    ])
    print("Firestore write OK for uid \(uid)")
  } catch {
    print("Firestore write failed:", error.localizedDescription)
  }
}
/// Reads the same document back and prints it.
@MainActor
func fh_readTestUser() async {
  do {
    guard let uid = Auth.auth().currentUser?.uid else {
      print("No signed-in user")
      return
    }
    let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
    if let data = doc.data() {
      print("Read user doc:", data)
    } else {
      print("Document not found")
    }
  } catch {
    print("Firestore read failed:", error.localizedDescription)
  }
}
