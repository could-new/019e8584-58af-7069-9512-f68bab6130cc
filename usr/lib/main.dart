import 'package:flutter/material.dart';

void main() {
  runApp(const FrancisMessengerApp());
}

class FrancisMessengerApp extends StatelessWidget {
  const FrancisMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrancisMessenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1877F2), // Facebook Blue
          primary: const Color(0xFF1877F2),
        ),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Post> _posts = [
    Post(
      authorName: 'Alice Dubois',
      timeAgo: 'Il y a 2 heures',
      content: 'Bonjour à tous ! Voici mon premier message sur FrancisMessenger.',
      likes: 12,
      comments: 3,
    ),
    Post(
      authorName: 'Jean Martin',
      timeAgo: 'Il y a 5 heures',
      content: 'Quelqu\'un sait comment faire une application Flutter qui fonctionne hors ligne ?',
      likes: 5,
      comments: 1,
    ),
    Post(
      authorName: 'Marie Curie',
      timeAgo: 'Hier à 14:30',
      content: 'La science, c\'est fantastique.',
      likes: 1024,
      comments: 42,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        title: const Text(
          'FrancisMessenger',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildFeed() : const Center(child: Text('Section en construction')),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Amis'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: 'Vidéos'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifs'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return ListView.builder(
      itemCount: _posts.length + 1, // +1 for the create post area
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCreatePostArea();
        }
        final post = _posts[index - 1];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildCreatePostArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Text(
                'Que voulez-vous dire ?',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          const Icon(Icons.photo_library, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        post.timeAgo,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 12.0),
          const Divider(height: 1, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPostAction(Icons.thumb_up_alt_outlined, 'J\'aime (${post.likes})'),
              _buildPostAction(Icons.comment_outlined, 'Commenter (${post.comments})'),
              _buildPostAction(Icons.share_outlined, 'Partager'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[700], size: 20),
      label: Text(
        label,
        style: TextStyle(color: Colors.grey[700]),
      ),
    );
  }
}

class Post {
  final String authorName;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;

  Post({
    required this.authorName,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
  });
}
