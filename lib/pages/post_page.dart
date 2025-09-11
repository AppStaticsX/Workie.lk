import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/client_post_screen.dart';
import '../screens/worker_post_screen.dart';

class PostPage extends StatefulWidget {
  final VoidCallback navigatePage;

  const PostPage({
    super.key,
    required this.navigatePage
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String selectedRole = '';

  @override
  void initState() {
    _loadUserRole();
    super.initState();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('USER_ROLE') ?? 'No data saved';
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedRole == 'job_seeker'
        ? WorkerPostScreen(onPostSuccess: widget.navigatePage)
        : ClientPostScreen();
  }
}