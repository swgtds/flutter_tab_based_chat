import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart'; //Optional: Include if you're using Audio/Video Calling
import 'screens/messages_screen.dart';
import 'cometchat_config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CometChat UI Kit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> _initializeAndLogin() async {
    final settings = UIKitSettingsBuilder()
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..autoEstablishSocketConnection = true
      ..appId = CometChatConfig.appId
      ..region = CometChatConfig.region
      ..authKey = CometChatConfig.authKey
      ..extensions = CometChatUIKitChatExtensions.getDefaultExtensions() //Replace this with empty array, if you want to disable all extensions
      ..callingExtension = CometChatCallingExtension(); //Optional: Include if you're using Audio/Video Calling

    await CometChatUIKit.init(uiKitSettings: settings.build());
    await CometChatUIKit.login(
      'cometchat-uid-1',
      onSuccess: (_) => debugPrint('✅ Login Successful'),
      onError: (err) => throw Exception('Login Failed: $err'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeAndLogin(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Text(
                  'Error starting app:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return const TabsScreen();
      },
    );
  }
}

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          CometChatConversations(
            showBackButton: false,
            onItemTap: (conversation) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesScreen(
                    user: conversation.conversationWith is User
                        ? conversation.conversationWith as User
                        : null,
                    group: conversation.conversationWith is Group
                        ? conversation.conversationWith as Group
                        : null,
                  ),
                ),
              );
            },
          ),
          CometChatCallLogs(),
          CometChatUsers(),
          CometChatGroups(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: "Calls",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Groups",
          ),
        ],
      ),
    );
  }
}