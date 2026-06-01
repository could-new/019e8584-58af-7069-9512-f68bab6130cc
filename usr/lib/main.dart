import 'package:flutter/material.dart';

void main() {
  runApp(const FrancisMessengerApp());
}

// ==========================================
// MODELS
// ==========================================

class User {
  final String id;
  final String name;
  final Color avatarColor;
  
  User({required this.id, required this.name, required this.avatarColor});
}

class Post {
  final String id;
  final String authorId;
  final String content;
  final DateTime timestamp;
  int likes;
  int comments;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
  });
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });
}

enum FriendStatus { none, pendingSent, pendingReceived, friends }

// ==========================================
// STATE MANAGEMENT (LOCAL/OFFLINE)
// ==========================================

class AppState extends ChangeNotifier {
  final User currentUser = User(id: 'u1', name: 'Moi (Vous)', avatarColor: Colors.blue);
  
  final List<User> allUsers = [
    User(id: 'u2', name: 'Alice Dubois', avatarColor: Colors.green),
    User(id: 'u3', name: 'Jean Martin', avatarColor: Colors.orange),
    User(id: 'u4', name: 'Marie Curie', avatarColor: Colors.purple),
    User(id: 'u5', name: 'Paul Dupont', avatarColor: Colors.teal),
  ];

  final Map<String, FriendStatus> friendStatuses = {
    'u2': FriendStatus.friends,
    'u3': FriendStatus.pendingReceived,
  };

  final List<Post> posts = [];
  final List<Message> messages = [];

  AppState() {
    // Initial Seed Data
    posts.add(Post(
      id: 'p1', authorId: 'u2', content: 'Bonjour à tous ! Voici mon premier message sur FrancisMessenger.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)), likes: 12, comments: 3,
    ));
    posts.add(Post(
      id: 'p2', authorId: 'u4', content: 'La science, c\'est fantastique.',
      timestamp: DateTime.now().subtract(const Duration(hours: 24)), likes: 1024, comments: 42,
    ));

    messages.add(Message(
      id: 'm1', senderId: 'u2', receiverId: 'u1', content: 'Salut ! Comment ça va ?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ));
  }

  // User Actions
  FriendStatus getFriendStatus(String userId) {
    return friendStatuses[userId] ?? FriendStatus.none;
  }

  void sendFriendRequest(String userId) {
    friendStatuses[userId] = FriendStatus.pendingSent;
    notifyListeners();
  }

  void acceptFriendRequest(String userId) {
    friendStatuses[userId] = FriendStatus.friends;
    notifyListeners();
  }

  void removeFriend(String userId) {
    friendStatuses[userId] = FriendStatus.none;
    notifyListeners();
  }

  // Post Actions
  void addPost(String content) {
    posts.insert(0, Post(
      id: DateTime.now().toString(),
      authorId: currentUser.id,
      content: content,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void toggleLike(String postId) {
    final post = posts.firstWhere((p) => p.id == postId);
    post.likes += 1; // Simplification
    notifyListeners();
  }

  // Message Actions
  void sendMessage(String receiverId, String content) {
    messages.add(Message(
      id: DateTime.now().toString(),
      senderId: currentUser.id,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    ));
    
    // Auto-reply mock logic
    if (receiverId != currentUser.id) {
      Future.delayed(const Duration(seconds: 1), () {
        messages.add(Message(
          id: DateTime.now().toString(),
          senderId: receiverId,
          receiverId: currentUser.id,
          content: 'Ceci est une réponse automatique de notre mode hors ligne.',
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      });
    }
    
    notifyListeners();
  }

  List<Message> getMessagesWith(String userId) {
    return messages.where((m) => 
      (m.senderId == currentUser.id && m.receiverId == userId) ||
      (m.senderId == userId && m.receiverId == currentUser.id)
    ).toList();
  }

  User getUser(String userId) {
    if (userId == currentUser.id) return currentUser;
    return allUsers.firstWhere((u) => u.id == userId);
  }
}

final AppState globalAppState = AppState();

// ==========================================
// APP & NAVIGATION
// ==========================================

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
        '/messages': (context) => const MessengerListScreen(),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/messages');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Amis'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const FeedScreen();
      case 1:
        return const FriendsScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Section en construction'));
    }
  }
}

// ==========================================
// SCREENS
// ==========================================

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _postController = TextEditingController();

  void _submitPost() {
    if (_postController.text.trim().isNotEmpty) {
      globalAppState.addPost(_postController.text.trim());
      _postController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalAppState,
      builder: (context, _) {
        return ListView.builder(
          itemCount: globalAppState.posts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCreatePostArea();
            }
            final post = globalAppState.posts[index - 1];
            return _buildPostCard(post);
          },
        );
      }
    );
  }

  Widget _buildCreatePostArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: globalAppState.currentUser.avatarColor,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    hintText: 'Que voulez-vous dire ?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _submitPost,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final author = globalAppState.getUser(post.authorId);
    final timeStr = _formatTime(post.timestamp);

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
                CircleAvatar(
                  backgroundColor: author.avatarColor,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
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
              TextButton.icon(
                onPressed: () => globalAppState.toggleLike(post.id),
                icon: Icon(Icons.thumb_up_alt_outlined, color: Colors.grey[700], size: 20),
                label: Text('J\'aime (${post.likes})', style: TextStyle(color: Colors.grey[700])),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.comment_outlined, color: Colors.grey[700], size: 20),
                label: Text('Commenter (${post.comments})', style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalAppState,
      builder: (context, _) {
        final pending = globalAppState.allUsers.where((u) => globalAppState.getFriendStatus(u.id) == FriendStatus.pendingReceived).toList();
        final suggestions = globalAppState.allUsers.where((u) => globalAppState.getFriendStatus(u.id) == FriendStatus.none).toList();
        final friends = globalAppState.allUsers.where((u) => globalAppState.getFriendStatus(u.id) == FriendStatus.friends).toList();
        final sent = globalAppState.allUsers.where((u) => globalAppState.getFriendStatus(u.id) == FriendStatus.pendingSent).toList();

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            if (pending.isNotEmpty) _buildSectionTitle('Demandes d\'amis (${pending.length})'),
            ...pending.map((u) => _buildUserCard(context, u, FriendStatus.pendingReceived)),
            
            if (friends.isNotEmpty) _buildSectionTitle('Vos amis (${friends.length})'),
            ...friends.map((u) => _buildUserCard(context, u, FriendStatus.friends)),
            
            if (suggestions.isNotEmpty) _buildSectionTitle('Personnes que vous connaissez peut-être'),
            ...suggestions.map((u) => _buildUserCard(context, u, FriendStatus.none)),

            if (sent.isNotEmpty) _buildSectionTitle('Invitations envoyées'),
            ...sent.map((u) => _buildUserCard(context, u, FriendStatus.pendingSent)),
          ],
        );
      }
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user, FriendStatus status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.avatarColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: _buildActionButton(user, status),
      ),
    );
  }

  Widget _buildActionButton(User user, FriendStatus status) {
    switch (status) {
      case FriendStatus.none:
        return ElevatedButton(
          onPressed: () => globalAppState.sendFriendRequest(user.id),
          child: const Text('Ajouter'),
        );
      case FriendStatus.pendingSent:
        return OutlinedButton(
          onPressed: () => globalAppState.removeFriend(user.id),
          child: const Text('Annuler'),
        );
      case FriendStatus.pendingReceived:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => globalAppState.acceptFriendRequest(user.id),
          child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
        );
      case FriendStatus.friends:
        return IconButton(
          icon: const Icon(Icons.person_remove, color: Colors.red),
          onPressed: () => globalAppState.removeFriend(user.id),
          tooltip: 'Retirer des amis',
        );
    }
  }
}

class MessengerListScreen extends StatelessWidget {
  const MessengerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: AnimatedBuilder(
        animation: globalAppState,
        builder: (context, _) {
          final friends = globalAppState.allUsers.where((u) => globalAppState.getFriendStatus(u.id) == FriendStatus.friends).toList();

          if (friends.isEmpty) {
            return const Center(child: Text('Ajoutez des amis pour discuter !'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: friend.avatarColor,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(friend.name),
                subtitle: const Text('Appuyez pour discuter'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(user: friend),
                    ),
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final User user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _send() {
    if (_msgController.text.trim().isNotEmpty) {
      globalAppState.sendMessage(widget.user.id, _msgController.text.trim());
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.user.avatarColor,
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(widget.user.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: globalAppState,
              builder: (context, _) {
                final msgs = globalAppState.getMessagesWith(widget.user.id).reversed.toList();
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final m = msgs[index];
                    final isMe = m.senderId == globalAppState.currentUser.id;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          m.content,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: globalAppState.currentUser.avatarColor,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            globalAppState.currentUser.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Connecté en mode hors ligne'),
        ],
      ),
    );
  }
}
