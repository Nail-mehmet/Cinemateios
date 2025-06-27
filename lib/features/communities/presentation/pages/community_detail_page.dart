import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';
import 'package:Cinemate/features/communities/presentation/components/community_post_card.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_bloc.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_event.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/profile/presentation/components/user_tile.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:uuid/uuid.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;
  final String currentUserId;
  final String communityName;

  const CommunityDetailPage({
    required this.communityId,
    required this.currentUserId,
    required this.communityName,
  });

  @override
  _CommunityDetailPageState createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _selectedImage;
  final _textController = TextEditingController();
  bool _isFabOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  final int _postsPerPage = 10;
  final _supabase = Supabase.instance.client;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<CommuneBloc>().add(LoadCommunes(
      communityId: widget.communityId,
      limit: _postsPerPage,
    ));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMorePosts) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    final state = context.read<CommuneBloc>().state;
    if (state is CommuneLoaded && state.communes.isNotEmpty) {
      final oldestPost = state.communes.last;
      _isLoadingMore = true;
      context.read<CommuneBloc>().add(LoadCommunes(
        communityId: widget.communityId,
        limit: _postsPerPage,
        lastFetched: oldestPost,
      ));
    }
  }

  Widget _buildFab() {
    if (_tabController.index != 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFabOpen) ...[
          FloatingActionButton.extended(
            heroTag: "textPost",
            onPressed: () {
              setState(() => _isFabOpen = false);
              _showTextPostSheet();
            },
            icon: const Icon(Icons.text_fields),
            label: const Text("Metin Gönder"),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "imagePost",
            onPressed: () {
              setState(() => _isFabOpen = false);
              _showImagePostSheet();
            },
            icon: const Icon(Icons.image),
            label: const Text("Fotoğraf Gönder"),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() => _isFabOpen = !_isFabOpen);
          },
          child: Icon(_isFabOpen ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  void _showTextPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Yeni Gönderi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: null,
                      maxLength: 500,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Ne paylaşmak istersin?',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(
                          'Paylaş',
                          style: AppTextStyles.bold.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          final commune = Commune(
                            id: _uuid.v4(),
                            text: _textController.text,
                            userId: widget.currentUserId,
                            createdAt: DateTime.now(),
                          );
                          context.read<CommuneBloc>().add(CreateCommune(
                            communityId: widget.communityId,
                            commune: commune,
                          ));
                          Navigator.pop(context);
                          _textController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  void _showImagePostSheet() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = picked != null ? File(picked.path) : null;
    });

    if (_selectedImage == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _textController,
                        maxLines: 8,
                        maxLength: 500,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Bir şeyler yaz...',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.tertiary,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        final commune = Commune(
                          id: _uuid.v4(),
                          text: _textController.text,
                          userId: widget.currentUserId,
                          createdAt: DateTime.now(),
                        );
                        context.read<CommuneBloc>().add(CreateCommune(
                          communityId: widget.communityId,
                          commune: commune,
                          image: _selectedImage,
                        ));
                        Navigator.pop(context);
                        _textController.clear();
                      },
                      child: Text(
                        'Paylaş',
                        style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.communityName,
          style: AppTextStyles.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    _isFabOpen = false;
                  });
                },
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Theme.of(context).colorScheme.tertiary,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                labelStyle: AppTextStyles.bold,
                tabs: const [
                  Tab(text: 'Gönderiler'),
                  Tab(text: 'Üyeler'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocConsumer<CommuneBloc, CommuneState>(
            listener: (context, state) {
              if (state is CommuneLoaded) {
                _isLoadingMore = false;
                _hasMorePosts = state.hasMore;
              }
            },
            builder: (context, state) {
              if (state is CommuneLoading && state.communes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CommuneError) {
                return Center(child: Text(state.message));
              }
              if (state is CommuneLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: state.communes.length + (_hasMorePosts ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.communes.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return CommuneCard(
                            post: state.communes[index],
                            currentUserId: widget.currentUserId,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text('Bir hata oluştu.'));
            },
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('community_members')
                .stream(primaryKey: ['community_id', 'user_id'])
                .eq('community_id', widget.communityId)
                .execute(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Henüz üye yok.'));
              }

              final memberIds = snapshot.data!.map((doc) => doc['user_id'] as String).toList();
              return ListView.builder(
                itemCount: memberIds.length,
                itemBuilder: (context, index) {
                  final uid = memberIds[index];
                  return FutureBuilder(
                    future: context.read<ProfileCubit>().getUserProfile(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final user = snapshot.data!;
                        return UserTile(user: user);
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Text("Yükleniyor..."),
                        );
                      } else {
                        return const ListTile(
                          title: Text("Kullanıcı bulunamadı"),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }
}