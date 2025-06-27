import 'package:Cinemate/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/settings/pages/help_center/help_center_page.dart';
import 'package:Cinemate/features/settings/pages/password_manager/update_password_page.dart';
import 'package:Cinemate/features/settings/pages/policies/privacy_policy_page.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:Cinemate/themes/theme_cubit.dart';
import 'package:Cinemate/features/auth/presentation/pages/register_page.dart'; // <=== Bunu kendi Register ya da Login sayfanla değiştir

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is DeleteAccountSuccess || state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterPage(),
            ),
            (route) => false,
          );
        } else if (state is DeleteAccountError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          print(state.message);
        }
      },
      child: _SettingsScaffold(),
    );
  }
}

class _SettingsScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildTile(
            icon: Icons.vpn_key_outlined,
            title: "Şifre Yöneticisi",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdatePasswordScreen(),
                ),
              );
            },
          ),
          _buildTile(
            icon: Icons.help_outline,
            title: "Yardım Merkezi",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterPage(),
                ),
              );
            },
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: "Gizlilik Ayarları",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(
              "Karanlık Mod",
              style: AppTextStyles.medium,
            ),
            trailing: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) => themeCubit.toggleTheme(),
            ),
          ),
          _buildLogoutButton(context),
          _buildDeleteAccountButton(context),
        ],
      ),
    );
  }

  Widget _buildTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: AppTextStyles.medium,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => context.read<AuthCubit>().logout(),
          icon: const Icon(Icons.logout),
          label: Text(
            "Çıkış Yap",
            style: AppTextStyles.bold,
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final authCubit = context.read<AuthCubit>();

            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Hesabı Sil'),
                content: const Text(
                    'Bu işlem geri alınamaz. Hesabınızı silmek istediğinize emin misiniz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(_, false),
                    child: const Text('Vazgeç'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(_, true),
                    child: const Text('Sil'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              authCubit.deleteAccount();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hesabınız siliniyor...')),
              );
            }
          },
          icon: const Icon(Icons.delete_forever),
          label: Text(
            "Hesabı Sil",
            style: AppTextStyles.bold,
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
