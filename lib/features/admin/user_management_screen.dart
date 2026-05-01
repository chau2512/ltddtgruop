import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../data/models/user_model.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  void _showEditUserModal(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quản lý: ${user.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Nút Khóa/Mở khóa
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isBlocked ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: Icon(user.isBlocked ? Icons.lock_open : Icons.lock),
              label: Text(user.isBlocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
              onPressed: () async {
                Navigator.pop(context); // Đóng modal
                await ref.read(adminRepositoryProvider).toggleUserBlockStatus(user.uid, user.isBlocked);
                ref.refresh(allUsersProvider); // Refresh lại list
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật trạng thái!')));
              },
            ),
            const SizedBox(height: 12),

            // Nút Đổi Role
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
              icon: const Icon(Icons.admin_panel_settings),
              label: Text(user.role == 'admin' ? 'Hạ cấp xuống User' : 'Nâng cấp lên Admin'),
              onPressed: () async {
                Navigator.pop(context);
                String newRole = user.role == 'admin' ? 'user' : 'admin';
                await ref.read(adminRepositoryProvider).changeUserRole(user.uid, newRole);
                ref.refresh(allUsersProvider);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật quyền!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách người dùng')),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) return const Center(child: Text('Chưa có người dùng nào.'));
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.role == 'admin' ? Colors.deepPurple : Colors.grey,
                  child: Icon(user.role == 'admin' ? Icons.security : Icons.person, color: Colors.white),
                ),
                title: Row(
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (user.isBlocked)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('(Bị khóa)', style: TextStyle(color: Colors.red, fontSize: 12)),
                      )
                  ],
                ),
                subtitle: Text('${user.email}\nTham gia: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditUserModal(context, ref, user),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}