import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_music/screens/main_screen.dart';
import 'package:ai_music/services/music_player.dart';
import 'package:ai_music/services/playlist_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicPlayer()),
        Provider(create: (_) => PlaylistService()),
      ],
      child: MaterialApp(
        title: 'AI Music Player',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}