import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:mobile/injection/injection.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/kyc/domain/entities/kyc_application_entity.dart';
import 'package:mobile/features/kyc/domain/usecases/get_kyc_applications_usecase.dart';
import 'package:mobile/features/kyc/presentation/pages/kyc_page.dart';

class KycGuard extends StatelessWidget {
  final Widget child;

  const KycGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<Failure, List<KycApplicationEntity>>>(
      future: getIt<GetKycApplicationsUseCase>().call(NoParams()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data!.fold(
          (failure) => Center(child: Text(failure.message)),
          (applications) {
            final hasApproved = applications.any(
                (a) => a.status == KycApplicationStatus.approved);
            if (hasApproved) {
              return child;
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'KYC verification required to access this feature.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const KycPage(),
                          ),
                        );
                      },
                      child: const Text('Complete KYC'),
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
}
