import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../trips/providers/trips_provider.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/models/user_model.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider);
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _phoneController = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      ref
          .read(profileProvider.notifier)
          .updateProfile(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            phone: _phoneController.text,
          );
      // TODO: Also update in Firestore if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _handleLogout() async {
    await ref.read(profileProvider.notifier).signOut();
  }

  Future<void> _handleChangePassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Nouveau mot de passe',
            hintText: 'Min 6 caractères',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != null && result.length >= 6) {
      try {
        await ref.read(profileProvider.notifier).updatePassword(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe mis à jour !'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte ?'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront effacées de Firebase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(profileProvider.notifier).deleteAccount();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: AppTheme.primaryGreen),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'À propos de\n LiftMosque',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LiftMosque est une application communautaire permettant aux fidèles d’organiser le covoiturage vers les mosquées et les activités associées.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Contact :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Email support : support@liftmosque.ca'),
              const Divider(height: 32),
              const Text(
                'LiftMosque est une plateforme de mise en relation entre utilisateurs. LiftMosque n’est pas une entreprise de transport.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text(
                'Liens :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/privacy-policy');
                },
                child: const Text('Politique de confidentialité'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/terms-of-use');
                },
                child: const Text("Conditions d'utilisation"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for data updates (e.g. once Firestore load completes)
    ref.listen(profileProvider, (previous, next) {
      if (!_isEditing && next.id.isNotEmpty) {
        _firstNameController.text = next.firstName;
        _lastNameController.text = next.lastName;
        _phoneController.text = next.phone;
      }
    });

    final user = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(user),
          const SizedBox(height: 32),
          _buildEditForm(),
          const SizedBox(height: 32),
          Text(
            "Paramètres du compte",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          // _buildProfileItem(Icons.history, 'Historique des trajets', () {}),
          // _buildProfileItem(Icons.settings_outlined, 'Paramètres', () {}),
          // _buildProfileItem(Icons.help_outline, 'Aide et support', () {}),
          _buildProfileItem(
            Icons.info_outline,
            'À propos',
            () => _showAboutDialog(context),
          ),
          const SizedBox(height: 32),
          Text(
            "Sécurité",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileItem(
            Icons.lock_reset,
            'Changer mot de passe',
            _handleChangePassword,
          ),
          _buildProfileItem(
            Icons.delete_forever,
            'Supprimer mon compte',
            _handleDeleteAccount,
            color: Colors.red.shade400,
          ),
          const Divider(height: 48),
          _buildProfileItem(
            Icons.logout,
            'Déconnexion',
            _handleLogout,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${user.firstName} ${user.lastName}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.phone,
            style: TextStyle(color: const Color.fromARGB(255, 7, 7, 7)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    if (!_isEditing) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: AppTheme.secondaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.secondaryBlue),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
