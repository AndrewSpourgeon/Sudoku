import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Text(user?.displayName ?? 'No Name'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user?.email != null)
            Text(user!.email!, style: const TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text('Sign Out'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await GoogleSignIn().signOut();
            await FirebaseAuth.instance.signOut();
            navigator.pop();
            navigator.pushReplacementNamed('/sign-in');
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
