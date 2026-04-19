import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/core/utils/url_utils.dart';

class BlogAuthorsSection extends StatelessWidget {
  const BlogAuthorsSection({super.key, required this.authors});
  final List<Map<String, dynamic>> authors;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text('Top Authors',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final author = authors[index];
              return Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: author['user']?['avatar'] != null
                        ? UrlUtils.normalise(author['user']['avatar'])
                        : '',
                    imageBuilder: (_, img) =>
                        CircleAvatar(radius: 32, backgroundImage: img),
                    placeholder: (_, __) => const CircleAvatar(radius: 32),
                    errorWidget: (_, __, ___) => CircleAvatar(
                      radius: 32,
                      child: Text((author['user']?['firstName'] ?? 'A')[0]),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 72,
                    child: Text(
                      author['user']?['firstName'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: authors.length,
          ),
        ),
      ],
    );
  }
}
