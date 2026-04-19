import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/utils/url_utils.dart';
import '../../domain/entities/blog_author_entity.dart';
import '../bloc/authors_bloc.dart';
import '../../../../../../injection/injection.dart';

class AuthorsListPage extends StatelessWidget {
  const AuthorsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthorsBloc>()..add(const AuthorsRequested()),
      child: const _AuthorsView(),
    );
  }
}

class _AuthorsView extends StatelessWidget {
  const _AuthorsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authors')),
      body: BlocBuilder<AuthorsBloc, AuthorsState>(
        builder: (context, state) {
          if (state is AuthorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthorsError) {
            return Center(child: Text(state.failure.message));
          }
          if (state is AuthorsLoaded) {
            final authors = state.authors;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: authors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12),
              itemBuilder: (context, index) {
                final author = authors[index];
                return _AuthorCard(author: author);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AuthorCard extends StatelessWidget {
  const _AuthorCard({required this.author});
  final BlogAuthorEntity author;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AuthorDetailPage(authorId: author.id)));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: author.user?.avatar != null
                  ? UrlUtils.normalise(author.user!.avatar!)
                  : '',
              imageBuilder: (ctx, img) =>
                  CircleAvatar(radius: 40, backgroundImage: img),
              placeholder: (_, __) => const CircleAvatar(radius: 40),
              errorWidget: (_, __, ___) => CircleAvatar(
                radius: 40,
                child: Text(author.user?.firstName.substring(0, 1) ?? 'A'),
              ),
            ),
            const SizedBox(height: 8),
            Text(author.user?.fullName ?? 'Unnamed',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${author.postCount} posts',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class AuthorDetailPage extends StatelessWidget {
  const AuthorDetailPage({super.key, required this.authorId});
  final String authorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthorsBloc>()..add(AuthorDetailRequested(authorId)),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<AuthorsBloc, AuthorsState>(builder: (context, state) {
          if (state is AuthorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthorsError) {
            return Center(child: Text(state.failure.message));
          }
          if (state is AuthorLoaded) {
            final author = state.author;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CachedNetworkImage(
                    imageUrl: author.user?.avatar != null
                        ? UrlUtils.normalise(author.user!.avatar!)
                        : '',
                    imageBuilder: (_, img) =>
                        CircleAvatar(radius: 60, backgroundImage: img),
                    placeholder: (_, __) => const CircleAvatar(radius: 60),
                    errorWidget: (_, __, ___) => CircleAvatar(
                        radius: 60,
                        child: Text(
                            author.user?.firstName.substring(0, 1) ?? 'A')),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                    child: Text(author.user?.fullName ?? '',
                        style: Theme.of(context).textTheme.headlineSmall)),
                const SizedBox(height: 8),
                if (author.bio != null) Text(author.bio!),
                const SizedBox(height: 24),
                Text('Posts', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (state.posts.isEmpty)
                  const Text('No posts yet')
                else
                  ...state.posts
                      .map((p) => ListTile(title: Text(p.title)))
                      ,
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
