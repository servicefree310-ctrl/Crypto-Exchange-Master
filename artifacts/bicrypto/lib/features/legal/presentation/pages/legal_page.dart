import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/legal_page_entity.dart';
import '../../domain/repositories/legal_repository.dart';

class LegalPage extends StatefulWidget {
  final LegalPageType pageType;

  const LegalPage({
    super.key,
    required this.pageType,
  });

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  final LegalRepository _repository = getIt<LegalRepository>();
  bool _isLoading = true;
  String? _error;
  LegalPageEntity? _page;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getLegalPage(widget.pageType.id);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (page) {
        setState(() {
          _isLoading = false;
          _page = page;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pageType.title,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPage,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_page == null) {
      return Center(
        child: Text(
          'No content available',
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: context.colors.primary,
      onRefresh: _loadPage,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Html(
          data: _page!.content,
          style: {
            "html": Style(
              color: context.textPrimary,
              fontSize: FontSize(16),
              lineHeight: const LineHeight(1.6),
            ),
            "h1": Style(
              color: context.textPrimary,
              fontSize: FontSize(28),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 16, top: 24),
            ),
            "h2": Style(
              color: context.textPrimary,
              fontSize: FontSize(24),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 12, top: 20),
            ),
            "h3": Style(
              color: context.textPrimary,
              fontSize: FontSize(20),
              fontWeight: FontWeight.w600,
              margin: Margins.only(bottom: 10, top: 16),
            ),
            "p": Style(
              color: context.textPrimary,
              fontSize: FontSize(16),
              margin: Margins.only(bottom: 12),
            ),
            "ul": Style(
              color: context.textPrimary,
              padding: HtmlPaddings.only(left: 20),
              margin: Margins.only(bottom: 12),
            ),
            "ol": Style(
              color: context.textPrimary,
              padding: HtmlPaddings.only(left: 20),
              margin: Margins.only(bottom: 12),
            ),
            "li": Style(
              color: context.textPrimary,
              margin: Margins.only(bottom: 8),
            ),
            "a": Style(
              color: context.colors.primary,
              textDecoration: TextDecoration.underline,
            ),
            "strong": Style(
              fontWeight: FontWeight.bold,
            ),
            "em": Style(
              fontStyle: FontStyle.italic,
            ),
          },
        ),
      ),
    );
  }
}
