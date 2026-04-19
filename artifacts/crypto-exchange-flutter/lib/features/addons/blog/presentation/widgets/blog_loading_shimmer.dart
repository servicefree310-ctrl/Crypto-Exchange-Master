import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BlogLoadingShimmer extends StatelessWidget {
  const BlogLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Shimmer.fromColors(
          baseColor: theme.cardColor,
          highlightColor: theme.highlightColor,
          child: Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Meta Info Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.cardColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                      8,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              width: index == 7
                                  ? MediaQuery.of(context).size.width * 0.6
                                  : double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlogListLoadingShimmer extends StatelessWidget {
  const BlogListLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Featured Posts Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Chips Shimmer
            Shimmer.fromColors(
              baseColor: theme.cardColor,
              highlightColor: theme.highlightColor,
              child: Row(
                children: List.generate(
                    4,
                    (index) => Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          child: Container(
                            width: 80,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )),
              ),
            ),

            const SizedBox(height: 24),

            // Post Cards Shimmer
            ...List.generate(
                6,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPostCardShimmer(context),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCardShimmer(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.cardColor,
      highlightColor: theme.highlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Shimmer
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),

            // Content Shimmer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Author and Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.cardColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 12,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 80,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
