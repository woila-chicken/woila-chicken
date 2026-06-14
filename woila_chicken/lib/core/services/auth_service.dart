import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_role.dart';
import '../routes/app_routes.dart';
import 'firebase_service.dart';

class AuthService extends GetxService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final currentUser = Rx<User?>(null);
  final userRole = Rx<UserRole?>(null);
  final isAdmin = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements d'auth
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        userRole.value = null;
        isAdmin.value = false;
      }
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        switch (role) {
          case 'admin':
            userRole.value = UserRole.admin;
            isAdmin.value = true;
            break;
          case 'eleveur':
            userRole.value = UserRole.eleveur;
            isAdmin.value = false;
            break;
          default:
            userRole.value = UserRole.client;
            isAdmin.value = false;
        }
      }
    } catch (e) {
      errorMessage.value = 'Erreur de chargement du profil';
    }
  }

  // ── Inscription ───────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await FirebaseService.getFcmToken();

      // Créer le profil dans Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'fcmToken': token,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Si éleveur → créer la ferme
      if (role == UserRole.eleveur) {
        await _db.collection('farms').add({
          'name': 'Ferme de $name',
          'ownerId': cred.user!.uid,
          'phone': phone,
          'location': '',
          'description': '',
          'rating': 0.0,
          'totalRatings': 0,
          'isVerified': false,
          'isSuspended': false,
          'certifications': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _authError(e.code);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Connexion ─────────────────────────────────────────────────
  Future<bool> login({
  required String email,
  required String password,
}) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ← Attendre que le rôle soit chargé AVANT de retourner
    await _loadUserRole(cred.user!.uid);

    // Mettre à jour le token FCM
    final token = await FirebaseService.getFcmToken();
    if (token != null) {
      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .update({'fcmToken': token});
    }

    return true;
  } on FirebaseAuthException catch (e) {
    errorMessage.value = _authError(e.code);
    return false;
  } finally {
    isLoading.value = false;
  }
}
  // ── Déconnexion ───────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Mot de passe oublié ───────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères min)';
      case 'invalid-email':
        return 'Email invalide';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      default:
        return 'Erreur de connexion. Réessayez';
    }
  }

  // Getters utiles
  String get uid => currentUser.value?.uid ?? '';
  bool get isLoggedIn => currentUser.value != null;
}