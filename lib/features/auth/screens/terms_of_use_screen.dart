import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions d'utilisation"),
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
              "CONDITIONS D'UTILISATION",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('1. Nature de l’application'),
            const Text(
              'L’application est une plateforme de mise en relation entre conducteurs et passagers.\n\n'
              'L’application n’offre pas de service de transport.\n\n'
              'La mosquée agit uniquement comme gestionnaire de la plateforme.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('2. Responsabilité des utilisateurs'),
            const Text(
              'Chaque utilisateur est responsable :\n'
              '• De son comportement\n'
              '• De ses trajets\n'
              '• De sa sécurité',
            ),
            const Divider(height: 32),
            _buildSectionTitle('3. Utilisation à vos risques'),
            const Text(
              'L’utilisation de l’application se fait aux risques de l’utilisateur.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('4. Limitation de responsabilité'),
            const Text(
              'La mosquée, les administrateurs et les développeurs ne peuvent être tenus responsables :\n'
              '• Des agressions\n'
              '• Des vols\n'
              '• Des accidents\n'
              '• Des conflits\n'
              '• Des blessures\n'
              '• Des pertes financières',
            ),
            const Divider(height: 32),
            _buildSectionTitle('5. Absence de garantie'),
            const Text(
              'L’application est fournie telle quelle sans garantie.\n\n'
              'Le fonctionnement continu n’est pas garanti.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('6. Protection développeur et admin'),
            const Text(
              'Les développeurs et administrateurs ne peuvent être tenus responsables :\n'
              '• Des actions des utilisateurs\n'
              '• Des erreurs techniques\n'
              '• Des problèmes de trajets',
            ),
            const Divider(height: 32),
            _buildSectionTitle('7. Identité des utilisateurs'),
            const Text(
              'La mosquée et les administrateurs ne garantissent pas :\n'
              '• L’identité des utilisateurs\n'
              '• La fiabilité des conducteurs\n'
              '• La sécurité des trajets',
            ),
            const Divider(height: 32),
            _buildSectionTitle('8. Obligations des utilisateurs'),
            const Text(
              'L’utilisateur doit :\n'
              '• Fournir des informations exactes\n'
              '• Respecter les autres utilisateurs\n'
              '• Respecter la loi',
            ),
            const Divider(height: 32),
            _buildSectionTitle('9. Suspension des comptes'),
            const Text(
              'La mosquée peut :\n'
              '• Suspendre un compte\n'
              '• Supprimer un compte\n\n'
              'Sans préavis.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('10. Indemnisation'),
            const Text(
              'L’utilisateur accepte de défendre et indemniser :\n'
              '• La mosquée\n'
              '• Les administrateurs\n'
              '• Les développeurs\n\n'
              'contre toute réclamation liée à l’utilisation de l’application.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('11. Application non professionnelle'),
            const Text(
              'L’application n’est pas un service commercial de transport.',
            ),
            const Divider(height: 32),
            _buildSectionTitle('12. Loi applicable'),
            const Text(
              'Cette application est régie par les lois du Québec et du Canada.',
            ),
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
