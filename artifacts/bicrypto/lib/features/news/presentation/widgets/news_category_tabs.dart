import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/news_entity.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_state.dart';

class NewsCategoryTabs extends StatelessWidget {
  const NewsCategoryTabs({
    super.key,
    required this.onCategoryChanged,
  });

  final Function(String?) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final categories = [
      const NewsCategoryEntity(
        id: 'all',
        name: 'All News',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'BTC',
        name: 'Bitcoin',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'ETH',
        name: 'Ethereum',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'DEFI',
        name: 'DeFi',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'NFT',
        name: 'NFTs',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'REG',
        name: 'Regulation',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'TECH',
        name: 'Technology',
        icon: '',
        isActive: true,
      ),
      const NewsCategoryEntity(
        id: 'MARKET',
        name: 'Market',
        icon: '',
        isActive: true,
      ),
    ];

    return Container(
      height: context.isSmallScreen ? 44.0 : 52.0,
      margin: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 12.0 : 16.0,
        vertical: context.isSmallScreen ? 8.0 : 12.0,
      ),
      child: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          String? selectedCategory;
          if (state is NewsLoaded) {
            selectedCategory = state.selectedCategory;
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == null
                  ? category.id == 'all'
                  : category.id == selectedCategory;

              return Padding(
                padding: EdgeInsets.only(
                  right: context.isSmallScreen ? 8.0 : 12.0,
                ),
                child: _buildCategoryChip(
                  context,
                  category,
                  isSelected,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    NewsCategoryEntity category,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onCategoryChanged(category.id == 'all' ? null : category.id);
        },
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 16.0 : 20.0,
            vertical: context.isSmallScreen ? 8.0 : 10.0,
          ),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : context.cardBackground,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: isSelected ? context.colors.primary : context.borderColor,
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Text(
            category.name,
            style: context.bodyS.copyWith(
              color: isSelected ? Colors.white : context.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: context.isSmallScreen ? 12.0 : 13.0,
            ),
          ),
        ),
      ),
    );
  }
}
