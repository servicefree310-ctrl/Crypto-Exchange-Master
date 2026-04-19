import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../domain/entities/kyc_level_entity.dart';
import '../../domain/entities/kyc_application_entity.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';
import '../widgets/kyc_level_card.dart';
import '../widgets/kyc_status_card.dart';
import 'kyc_form_page.dart';

final sl = GetIt.instance;

class KycPage extends StatelessWidget {
  const KycPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<KycBloc>()..add(const KycLevelsLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'KYC Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const _KycPageBody(),
      ),
    );
  }
}

class _KycPageBody extends StatefulWidget {
  const _KycPageBody();

  @override
  State<_KycPageBody> createState() => _KycPageBodyState();
}

class _KycPageBodyState extends State<_KycPageBody> {
  List<KycLevelEntity>? _levels;
  List<KycApplicationEntity>? _applications;
  bool _levelsLoaded = false;
  bool _applicationsLoaded = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is KycLevelsLoaded) {
          setState(() {
            _levels = state.levels;
            _levelsLoaded = true;
          });
          // Now load applications
          context.read<KycBloc>().add(const KycApplicationsLoadRequested());
        } else if (state is KycApplicationsLoaded) {
          setState(() {
            _applications = state.applications;
            _applicationsLoaded = true;
          });
        }
      },
      builder: (context, state) {
        if (state is KycLoading && !_levelsLoaded) {
          return LoadingWidget(message: state.message);
        }

        if (state is KycError && !_levelsLoaded) {
          return core.ErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<KycBloc>().add(const KycLevelsLoadRequested());
            },
          );
        }

        if (_levels != null) {
          return _buildContent(context);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _levelsLoaded = false;
          _applicationsLoaded = false;
        });
        context.read<KycBloc>().add(const KycLevelsLoadRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KYC Status Card (now dynamic)
            KycStatusCard(applications: _applications),
            const SizedBox(height: 24),

            // KYC Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About KYC Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Know Your Customer (KYC) verification helps us ensure the security of your account and comply with regulatory requirements. Complete verification to unlock all platform features.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Available KYC Levels
            Text(
              'Verification Levels',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),

            // KYC Levels List
            if (_levels!.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No KYC levels available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KYC verification levels will appear here when available.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._levels!.map((level) {
                // Find existing application for this level
                final existingApp =
                    _applications?.where((a) => a.levelId == level.id);
                final app = existingApp != null && existingApp.isNotEmpty
                    ? existingApp.first
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: KycLevelCard(
                    level: level,
                    onTap: () => _navigateToKycForm(context, level, app),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _navigateToKycForm(
    BuildContext context,
    KycLevelEntity level,
    KycApplicationEntity? existingApp,
  ) {
    // Don't allow navigation if already approved
    if (existingApp?.status == KycApplicationStatus.approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This level is already approved'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Don't allow if pending
    if (existingApp?.status == KycApplicationStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application is pending review'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    // Allow if rejected or additional info required (pass existing app for update)
    final appToUpdate = (existingApp?.status == KycApplicationStatus.rejected ||
            existingApp?.status == KycApplicationStatus.additionalInfoRequired)
        ? existingApp
        : null;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => KycFormPage(
          levelId: level.id,
          existingApplication: appToUpdate,
        ),
      ),
    )
        .then((result) {
      if (result == true) {
        // Refresh the page
        setState(() {
          _levelsLoaded = false;
          _applicationsLoaded = false;
        });
        context.read<KycBloc>().add(const KycLevelsLoadRequested());
      }
    });
  }
}
