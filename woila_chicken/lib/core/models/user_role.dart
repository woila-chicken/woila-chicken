enum UserRole { client, eleveur, admin }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.client:  return 'Client';
      case UserRole.eleveur: return 'Éleveur';
      case UserRole.admin:   return 'Administrateur';
    }
  }
  String get description {
    switch (this) {
      case UserRole.client:  return 'Acheter des poulets frais';
      case UserRole.eleveur: return 'Gérer ma ferme et mes ventes';
      case UserRole.admin:   return 'Superviser la plateforme';
    }
  }
}
