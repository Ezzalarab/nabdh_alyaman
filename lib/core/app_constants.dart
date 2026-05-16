class AppConstants {
  /// **SECURITY:** Legacy FCM HTTP — these constants must be deleted from the app.
  /// BACKEND: Notification delivery is server-only (Firebase Admin / REST). Rotate any
  /// exposed key in Firebase Console after removing from the client.
  static const String baseUrl = 'https://fcm.googleapis.com/fcm/send';
  static const String serverKey =
      'AAAA38t9Pf8:APA91bHd0hEzCkV3I2p-fNMcOefQ1qPB33maAXXHMdf8fYy-oAkbyBBkGd4qKNR50j8P8QHb0gJwWOG4ejoGpbwaZw526MHofn3kb4HsQfyGW2j5ooAPIxdVtyFSC6wX9-JiAtspHITX';
  static const String senderId = '961191689727';
}
