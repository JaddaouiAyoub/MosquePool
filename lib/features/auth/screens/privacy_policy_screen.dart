import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'POLITIQUE DE CONFIDENTIALITÉ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cette politique de confidentialité s’applique à l’application LiftMosque (ci-après appelée “l’application”).',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('1. Introduction'),
            const Text(
              'Cette politique de confidentialité décrit la façon dont l’application de covoiturage de la mosquée collecte, utilise et protège les renseignements personnels des utilisateurs.\n\n'
              'L’application a pour objectif de mettre en relation des conducteurs et des passagers se rendant vers la mosquée.\n\n'
              'En utilisant l’application, vous acceptez la collecte et l’utilisation de vos renseignements conformément à cette politique.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('2. Responsable des renseignements personnels'),
            const Text(
              'Responsable de la protection des renseignements personnels :\n\n'
              'Mosquée : ______\n'
              'Email : ______\n'
              'Téléphone : ______',
            ),
            const Divider(height: 32),
            _buildSectionTitle('3. Renseignements collectés'),
            const Text(
              'L’application peut collecter :\n\n'
              'Informations de base\n'
              '• Nom\n'
              '• Numéro de téléphone\n'
              '• Adresse courriel\n'
              '• Photo de profil\n\n'
              'Informations techniques\n'
              '• Adresse IP\n'
              '• Type d’appareil\n'
              '• Identifiant utilisateur\n'
              '• Logs techniques\n\n'
              'Informations liées aux trajets\n'
              '• Lieu de départ\n'
              '• Destination\n'
              '• Horaires\n'
              '• Historique des trajets\n\n'
              'Ces informations sont nécessaires pour le fonctionnement de l’application.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('4. Finalité de la collecte'),
            const Text(
              'Les renseignements sont collectés pour :\n'
              '• Créer les comptes utilisateurs\n'
              '• Permettre les trajets\n'
              '• Mettre en relation conducteurs et passagers\n'
              '• Assurer la sécurité de la plateforme\n'
              '• Prévenir les abus\n'
              '• Gérer les comptes\n'
              '• Améliorer l’application',
            ),
            const Divider(height: 32),
            _buildSectionTitle('5. Accès aux renseignements'),
            const Text(
              'Peuvent avoir accès aux renseignements :\n'
              '• Les administrateurs de l’application\n'
              '• La mosquée gestionnaire\n'
              '• Les développeurs techniques si nécessaire\n\n'
              'Les renseignements ne sont pas vendus à des tiers.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('6. Partage d’informations'),
            const Text(
              'Les informations peuvent être visibles par d’autres utilisateurs :\n'
              '• Nom\n'
              '• Photo\n'
              '• Numéro téléphone\n'
              '• Trajet proposé\n\n'
              'Cela est nécessaire pour permettre le covoiturage.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('7. Sécurité'),
            const Text(
              'Nous utilisons des mesures de sécurité raisonnables pour protéger les renseignements :\n'
              '• Accès restreint\n'
              '• Protection des comptes\n'
              '• Sécurisation des serveurs\n\n'
              'Les renseignements personnels peuvent être hébergés et traités par des fournisseurs technologiques sécurisés nécessaires au fonctionnement de l’application, notamment des services d’hébergement informatique.\n'
              'Ces fournisseurs peuvent stocker les données sur des serveurs situés à l’extérieur du Québec ou du Canada.\n'
              'LiftMosque prend des mesures raisonnables pour assurer la protection des renseignements personnels.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('8. Conservation des données'),
            const Text(
              'Les données sont conservées :\n'
              '• Tant que le compte est actif\n'
              '• Maximum 24 mois après inactivité',
            ),
            const Divider(height: 32),
            _buildSectionTitle('9. Droits des utilisateurs'),
            const Text(
              'Vous avez le droit :\n'
              '• D’accéder à vos données\n'
              '• De corriger vos données\n'
              '• De supprimer votre compte',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('10. Consentement'),
            const Text(
              'En créant un compte, l’utilisateur accepte la collecte des renseignements nécessaires au fonctionnement de l’application.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('11. Modifications'),
            const Text('Cette politique peut être modifiée en tout temps.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
