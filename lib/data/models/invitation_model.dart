import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus { pending, accepted, declined }

class InvitationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String receiverId;
  final String projectId;
  final String projectTitle;
  final String status; // pending, accepted, declined
  final DateTime timestamp;

  InvitationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.receiverId,
    required this.projectId,
    required this.projectTitle,
    this.status = 'pending',
    required this.timestamp,
  });

  factory InvitationModel.fromMap(Map<String, dynamic> map, String docId) {
    return InvitationModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'],
      receiverId: map['receiverId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverId': receiverId,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
