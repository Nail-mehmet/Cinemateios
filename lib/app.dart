import 'dart:async';
import 'dart:io';


import 'package:Cinemate/features/chats/chat_bloc.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:Cinemate/features/chats/message_bloc.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:http/http.dart' as http;

// Auth
import 'package:Cinemate/features/auth/data/firebase_auth_repo.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_states.dart';
import 'package:Cinemate/features/auth/presentation/pages/auth_page.dart';
import 'package:Cinemate/features/auth/presentation/pages/nav_bar.dart';
import 'package:Cinemate/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:Cinemate/features/communities/domain/repository/community_repository.dart';

// Profile
import 'package:Cinemate/features/profile/data/firebase_profile_repo.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';

// Post
import 'package:Cinemate/features/post/data/firebase_post_repo.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_cubit.dart';
// Search
import 'package:Cinemate/features/search/data/firebase_search_repo.dart';
import 'package:Cinemate/features/search/presentation/cubits/search_cubit.dart';

// Storage
import 'package:Cinemate/features/storage/data/firebase_storage_repo.dart';

// Movies
import 'package:Cinemate/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:Cinemate/features/movies/data/datasources/movie_detail_remote_data_source.dart';
import 'package:Cinemate/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:Cinemate/features/movies/data/repositories/movie_detail_repository_impl.dart';
import 'package:Cinemate/features/movies/domain/repos/movie_repository.dart';
import 'package:Cinemate/features/movies/presentation/cubits/movie_cubit.dart';
import 'package:Cinemate/features/movies/presentation/cubits/movie_detail_cubit.dart';

// Chat

// Theme
import 'package:Cinemate/themes/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:url_launcher/url_launcher.dart';

import 'config/home_widget_helper.dart';
import 'features/actors/domain/actor_repository.dart';
import 'features/communities/presentation/cubits/commune_bloc.dart';
import 'features/premium/data/premium_provider.dart';

class MyApp extends StatefulWidget {
  final bool forceUpdateRequired;
  const MyApp({super.key, required this.forceUpdateRequired});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  @override
  Widget build(BuildContext context) {
    final firebaseAuthRepo = SupabaseAuthRepo();
    //final firebaseProfileRepo = FirebaseProfileRepo();
    final firebaseStorageRepo = SupabaseStorageRepo();
    final firebasePostRepo = SupabasePostRepo();
    final firebaseSearchRepo = FirebaseSearchRepo();

   // final chatRemoteDataSource = ChatRemoteDataSource();

   /* void initState() {
      super.initState();
      WidgetsBinding.instance.addObserver(this);
      WidgetHelper.updateWidgetFromFirebase(); // Uygulama açıldığında
    }

    void didChangeAppLifecycleState(AppLifecycleState state) {
      if (state == AppLifecycleState.resumed) {
        WidgetHelper.updateWidgetFromFirebase(); // Uygulama tekrar açıldığında
      }
    }

    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }
*/
    final movieRepo = MovieRepositoryImpl(
      MovieRemoteDataSource(
        http.Client(),
        '7bd28d1b496b14987ce5a838d719c5c7',
      ),
    );

    final movieDetailRepo = MovieDetailRepositoryImpl(
      MovieDetailRemoteDataSource(
        http.Client(),
        '7bd28d1b496b14987ce5a838d719c5c7',
      ),
    );

    if (widget.forceUpdateRequired) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: AlertDialog(
              title: Text('Zorunlu Güncelleme',style: AppTextStyles.bold,),
              content: Text('Devam etmek için uygulamayı güncellemeniz gerekiyor.',style: AppTextStyles.medium,),
              actions: [
                TextButton(
                  onPressed: () async {
                    final androidUrl = 'https://play.google.com/store/apps/details?id=com.example.app';
                    final iosUrl = 'https://apps.apple.com/app/idXXXXXXXXX'; // iOS App Store linkinizi girin
                    final url = Platform.isAndroid ? androidUrl : iosUrl;                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                  child: Text('Güncelle'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MovieRepository>.value(value: movieRepo),
        RepositoryProvider<MovieDetailRepository>.value(value: movieDetailRepo),
        RepositoryProvider<ActorRepository>(
          create: (context) => ActorRepository(),
        ),
        //RepositoryProvider<ChatRemoteDataSource>.value(value: chatRemoteDataSource),
       // RepositoryProvider<ChatRepository>.value(
       //   value: ChatRepositoryImpl(remoteDataSource: chatRemoteDataSource),
       // ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
          ),

          BlocProvider<ChatBloc>(
            create: (_) => ChatBloc(chatRepository: ChatRepository(supabaseClient: Supabase.instance.client)),
          ),
          BlocProvider<MessageBloc>(
            create: (_) => MessageBloc(chatRepository: ChatRepository(supabaseClient: Supabase.instance.client)),
          ),
         BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              profileRepo: SupabaseProfileRepo(),
              storageRepo: firebaseStorageRepo,
            ),
          ),
          BlocProvider(
          create: (_) => CommuneBloc(CommuneRepository()),
        ),
          BlocProvider<PostCubit>(
            create: (context) => PostCubit(
              postRepo: firebasePostRepo,
              storageRepo: firebaseStorageRepo,
            ),
          ),
         BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
          ),
          BlocProvider<MovieCubit>(
            create: (context) => MovieCubit(movieRepo: movieRepo)..fetchMovies(),
          ),
          BlocProvider<MovieDetailCubit>(
            create: (context) => MovieDetailCubit(movieDetailRepo),
          ),

          /*BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
              getChats: GetChats(repository: context.read<ChatRepository>()),
              getMessages: GetMessages(repository: context.read<ChatRepository>()),
              sendMessage: SendMessage(repository: context.read<ChatRepository>()),
              startChat: StartChat(repository: context.read<ChatRepository>()),
              markMessageAsRead: MarkMessageAsRead(repository: context.read<ChatRepository>())
            ),
          ),*/
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],
        child: const AppContent(),
      ),
    );
  }
}
class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeCubit>().state,
      home: const InitialPage(),
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool _isLoading = true;
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;

    setState(() {
      _seenOnboarding = seen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _seenOnboarding ? const SplashScreen() : const OnboardingPage();
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigated = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Stream dinleyicisini iptal et
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return; // widget hâlâ ekranda mı?

    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    if (authState is Authenticated || authState is Unauthenticated) {
      _navigateNext();
    } else {
      _authSubscription = authCubit.stream.listen((state) {
        if (!mounted) return;
        if (!_isNavigated &&
            (state is Authenticated || state is Unauthenticated)) {
          _navigateNext();
        }
      });
    }
  }

  void _navigateNext() {
    if (!_isNavigated && mounted) {
      _isNavigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: Center(
        child: Lottie.asset(
          'assets/lotties/negro.json',
          width: 400,
          height: 400,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}



class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is Unauthenticated) {
          return const AuthPage();
        }
        if (state is Authenticated) {
          return const NavBar();
        }
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        );
      },
    );
  }
}