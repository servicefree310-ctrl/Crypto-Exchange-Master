import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../bloc/profile_bloc.dart';
import '../../../../injection/injection.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipController = TextEditingController();
  final _twitterController = TextEditingController();
  final _dribbbleController = TextEditingController();
  final _instagramController = TextEditingController();
  final _githubController = TextEditingController();
  final _gitlabController = TextEditingController();
  final _telegramController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    _twitterController.dispose();
    _dribbbleController.dispose();
    _instagramController.dispose();
    _githubController.dispose();
    _gitlabController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  void _loadProfileData(ProfileEntity profile) {
    dev.log('🔵 EDIT_PROFILE_PAGE: Loading profile data');

    // Basic user info
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone ?? '';

    // Extended profile info
    if (profile.profile != null) {
      _bioController.text = profile.profile!.bio ?? '';

      // Location
      if (profile.profile!.location != null) {
        _addressController.text = profile.profile!.location!.address ?? '';
        _cityController.text = profile.profile!.location!.city ?? '';
        _countryController.text = profile.profile!.location!.country ?? '';
        _zipController.text = profile.profile!.location!.zip ?? '';
      }

      // Social links
      if (profile.profile!.social != null) {
        _twitterController.text = profile.profile!.social!.twitter ?? '';
        _dribbbleController.text = profile.profile!.social!.dribbble ?? '';
        _instagramController.text = profile.profile!.social!.instagram ?? '';
        _githubController.text = profile.profile!.social!.github ?? '';
        _gitlabController.text = profile.profile!.social!.gitlab ?? '';
        _telegramController.text = profile.profile!.social!.telegram ?? '';
      }
    }

    dev.log('🟢 EDIT_PROFILE_PAGE: Profile data loaded successfully');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('🔵 EDIT_PROFILE_PAGE: Building edit profile page');

    return BlocProvider.value(
      value: getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Profile',
            style: context.h5,
          ),
          actions: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is ProfileUpdating
                      ? null
                      : () => _saveProfile(context),
                  child: Text(
                    state is ProfileUpdating ? 'Saving...' : 'Save',
                    style: context.labelL.copyWith(
                      color: state is ProfileUpdating
                          ? context.textTertiary
                          : context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _loadProfileData(state.profile);
            } else if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: context.priceUpColor),
                      const SizedBox(width: 12),
                      Text('Profile updated successfully!'),
                    ],
                  ),
                  backgroundColor: context.cardBackground,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context);
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error, color: context.priceDownColor),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Error: ${state.message}')),
                    ],
                  ),
                  backgroundColor: context.cardBackground,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: context.colors.primary,
                ),
              );
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: context.horizontalPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildPersonalInfoCard(context),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                    const SizedBox(height: 16),
                    _buildLocationCard(context),
                    const SizedBox(height: 16),
                    _buildSocialLinksCard(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return _buildCard(
      context: context,
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompactTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter first name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter last name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return _buildCard(
      context: context,
      title: 'About',
      icon: Icons.info_outline,
      children: [
        _buildCompactTextField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Tell us about yourself',
          maxLines: 3,
          prefixIcon: Icons.edit_outlined,
        ),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return _buildCard(
      context: context,
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        _buildCompactTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter your address',
          prefixIcon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCompactTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactTextField(
                controller: _zipController,
                label: 'ZIP Code',
                hint: 'Enter ZIP',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _countryController,
          label: 'Country',
          hint: 'Enter country',
          prefixIcon: Icons.public_outlined,
        ),
      ],
    );
  }

  Widget _buildSocialLinksCard(BuildContext context) {
    return _buildCard(
      context: context,
      title: 'Social Links',
      icon: Icons.link_outlined,
      children: [
        _buildSocialField(
          controller: _twitterController,
          label: 'Twitter',
          hint: 'twitter.com/username',
          icon: Icons.flutter_dash,
          color: const Color(0xFF1DA1F2),
        ),
        const SizedBox(height: 12),
        _buildSocialField(
          controller: _instagramController,
          label: 'Instagram',
          hint: 'instagram.com/username',
          icon: Icons.camera_alt_outlined,
          color: const Color(0xFFE4405F),
        ),
        const SizedBox(height: 12),
        _buildSocialField(
          controller: _githubController,
          label: 'GitHub',
          hint: 'github.com/username',
          icon: Icons.code_outlined,
          color: const Color(0xFF333333),
        ),
        const SizedBox(height: 12),
        _buildSocialField(
          controller: _telegramController,
          label: 'Telegram',
          hint: '@username',
          icon: Icons.send_outlined,
          color: const Color(0xFF0088CC),
        ),
        const SizedBox(height: 12),
        _buildSocialField(
          controller: _dribbbleController,
          label: 'Dribbble',
          hint: 'dribbble.com/username',
          icon: Icons.sports_basketball_outlined,
          color: const Color(0xFFEA4C89),
        ),
        const SizedBox(height: 12),
        _buildSocialField(
          controller: _gitlabController,
          label: 'GitLab',
          hint: 'gitlab.com/username',
          icon: Icons.merge_type_outlined,
          color: const Color(0xFFFC6D26),
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: context.colors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.labelM.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: context.bodyM.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.bodyS.copyWith(color: context.textTertiary),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: context.textTertiary, size: 18)
                  : null,
              filled: true,
              fillColor: context.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.colors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.priceDownColor, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.priceDownColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.labelS.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: context.bodyS.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.bodyS.copyWith(color: context.textTertiary),
              filled: true,
              fillColor: context.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile(BuildContext context) {
    dev.log('🔵 EDIT_PROFILE_PAGE: Save profile button pressed');

    if (_formKey.currentState!.validate()) {
      dev.log('🔵 EDIT_PROFILE_PAGE: Form validation passed');

      // Create profile entities
      final profileInfo = ProfileInfoEntity(
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        location: LocationEntity(
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          city: _cityController.text.isNotEmpty ? _cityController.text : null,
          country: _countryController.text.isNotEmpty
              ? _countryController.text
              : null,
          zip: _zipController.text.isNotEmpty ? _zipController.text : null,
        ),
        social: SocialLinksEntity(
          twitter: _twitterController.text.isNotEmpty
              ? _twitterController.text
              : null,
          dribbble: _dribbbleController.text.isNotEmpty
              ? _dribbbleController.text
              : null,
          instagram: _instagramController.text.isNotEmpty
              ? _instagramController.text
              : null,
          github:
              _githubController.text.isNotEmpty ? _githubController.text : null,
          gitlab:
              _gitlabController.text.isNotEmpty ? _gitlabController.text : null,
          telegram: _telegramController.text.isNotEmpty
              ? _telegramController.text
              : null,
        ),
      );

      final updateParams = UpdateProfileParams(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        profile: profileInfo,
      );

      context.read<ProfileBloc>().add(ProfileUpdateRequested(updateParams));
    }
  }
}
