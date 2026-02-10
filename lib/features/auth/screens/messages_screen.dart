import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryGreen),
            ),
            title: Text('Driver ${index + 1}'),
            subtitle: const Text('Salam, is the ride still available?'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '14:20',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (index < 2)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
