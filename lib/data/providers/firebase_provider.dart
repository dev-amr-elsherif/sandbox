import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/invitation_model.dart';

class FirebaseProvider {
  // هذا الكلاس هو "الدينامو" اللي بيكلم الفايربيز مباشرة بدون لف ودوران
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // حفظ بيانات المستخدم بعد أول تسجيل دخول - مهم جداً لإنشاء البروفايل
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // جلب بيانات مستخدم معين
  Future<UserModel?> getUser(String uid) async {
    var doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // جلب كل المشاريع المتاحة
  Future<List<ProjectModel>> getProjects() async {
    var snapshot = await _firestore.collection('projects').get();
    return snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;
      return ProjectModel.fromMap(data);
    }).toList();
  }

  // إنشاء مشروع جديد
  Future<ProjectModel> createProject(ProjectModel project) async {
    var doc = await _firestore.collection('projects').add(project.toMap());
    var data = project.toMap();
    data['id'] = doc.id;
    return ProjectModel.fromMap(data);
  }

  // جلب كل المطورين
  Future<List<UserModel>> getDevelopers() async {
    var snapshot = await _firestore.collection('users').where('role', isEqualTo: 'developer').get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  // ─── Invitations ───

  // إرسال دعوة لمطور
  Future<void> sendInvitation(InvitationModel invitation) async {
    await _firestore.collection('invitations').add(invitation.toMap());
  }

  // الاستماع للدعوات الجديدة (للمطور)
  Stream<List<InvitationModel>> streamInvitations(String userId) {
    return _firestore
        .collection('invitations')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvitationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // تحديث حالة الدعوة (قبول/رفض)
  Future<void> updateInvitationStatus(String invitationId, String newStatus) async {
    await _firestore
        .collection('invitations')
        .doc(invitationId)
        .update({'status': newStatus});
  }

  // الاستماع للدعوات المرسلة وحالتها (لصاحب المشروع)
  Stream<List<InvitationModel>> streamSentInvitations(String ownerId) {
    return _firestore
        .collection('invitations')
        .where('senderId', isEqualTo: ownerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvitationModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
