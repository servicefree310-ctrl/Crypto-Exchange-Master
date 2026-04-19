import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 7: Location Settings - V5 Compatible Mobile Implementation
class Step7LocationSettings extends StatefulWidget {
  const Step7LocationSettings({super.key});

  @override
  State<Step7LocationSettings> createState() => _Step7LocationSettingsState();
}

class _Step7LocationSettingsState extends State<Step7LocationSettings> {
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _restrictionController = TextEditingController();

  String _selectedCountry = '';
  List<String> _restrictions = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _regionController.dispose();
    _cityController.dispose();
    _restrictionController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final bloc = context.read<CreateOfferBloc>();
    final state = bloc.state;

    if (state is CreateOfferEditing) {
      final locationSettings =
          state.formData['locationSettings'] as Map<String, dynamic>?;
      if (locationSettings != null) {
        _selectedCountry = locationSettings['country'] ?? '';
        _regionController.text = locationSettings['region'] ?? '';
        _cityController.text = locationSettings['city'] ?? '';
        _restrictions =
            List<String>.from(locationSettings['restrictions'] ?? []);
      }
    }
  }

  void _updateLocationSettings() {
    final bloc = context.read<CreateOfferBloc>();

    bloc.add(CreateOfferSectionUpdated(
      section: 'locationSettings',
      data: {
        'country': _selectedCountry,
        'region': _regionController.text.trim(),
        'city': _cityController.text.trim(),
        'restrictions': _restrictions,
      },
    ));
  }

  void _addRestriction() {
    final restriction = _restrictionController.text.trim();
    if (restriction.isNotEmpty && !_restrictions.contains(restriction)) {
      setState(() {
        _restrictions.add(restriction);
        _restrictionController.clear();
      });
      _updateLocationSettings();
    }
  }

  void _removeRestriction(String restriction) {
    setState(() {
      _restrictions.remove(restriction);
    });
    _updateLocationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferBloc, CreateOfferState>(
      builder: (context, state) {
        if (state is! CreateOfferEditing) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              if (_selectedCountry.isEmpty) _buildRequiredAlert(context),
              const SizedBox(height: 16),
              _buildLocationCard(context),
              const SizedBox(height: 16),
              _buildRestrictionsCard(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Specify your location and trading preferences to help match with nearby traders',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredAlert(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Country selection is required to create a P2P offer. This helps match you with nearby traders and ensures compliance with local regulations.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Trading Location',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Specify where you are located for better matching',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Country Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Country',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Required',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCountryDropdown(context),
              ],
            ),

            const SizedBox(height: 16),

            // Region/State Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Region/State',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Optional',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _regionController,
                  decoration: InputDecoration(
                    hintText: 'e.g., California',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) => _updateLocationSettings(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // City Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'City',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Optional',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'e.g., San Francisco',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) => _updateLocationSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryDropdown(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
            color: _selectedCountry.isEmpty
                ? Colors.red.shade300
                : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry.isEmpty ? null : _selectedCountry,
          isExpanded: true,
          hint: Text(
            'Select country (required)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          items: _getCountries().map((country) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Text(country['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCountry = value;
              });
              _updateLocationSettings();
            }
          },
        ),
      ),
    );
  }

  Widget _buildRestrictionsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.public,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Geographical Restrictions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Specify any countries or regions you cannot trade with',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add restriction input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _restrictionController,
                    decoration: InputDecoration(
                      hintText: 'Add a country or region to exclude',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (value) => _addRestriction(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addRestriction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Display restrictions
            if (_restrictions.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _restrictions.map((restriction) {
                  return Chip(
                    label: Text(restriction),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeRestriction(restriction),
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    deleteIconColor: theme.primaryColor,
                  );
                }).toList(),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No restrictions added yet. You can trade with all countries.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Adding geographical restrictions helps focus on your preferred markets and may improve matching.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getCountries() {
    // Complete list of countries matching V5
    return [
      {"code": "AF", "name": "Afghanistan"},
      {"code": "AX", "name": "Åland Islands"},
      {"code": "AL", "name": "Albania"},
      {"code": "DZ", "name": "Algeria"},
      {"code": "AS", "name": "American Samoa"},
      {"code": "AD", "name": "Andorra"},
      {"code": "AO", "name": "Angola"},
      {"code": "AI", "name": "Anguilla"},
      {"code": "AQ", "name": "Antarctica"},
      {"code": "AG", "name": "Antigua and Barbuda"},
      {"code": "AR", "name": "Argentina"},
      {"code": "AM", "name": "Armenia"},
      {"code": "AW", "name": "Aruba"},
      {"code": "AU", "name": "Australia"},
      {"code": "AT", "name": "Austria"},
      {"code": "AZ", "name": "Azerbaijan"},
      {"code": "BS", "name": "Bahamas"},
      {"code": "BH", "name": "Bahrain"},
      {"code": "BD", "name": "Bangladesh"},
      {"code": "BB", "name": "Barbados"},
      {"code": "BY", "name": "Belarus"},
      {"code": "BE", "name": "Belgium"},
      {"code": "BZ", "name": "Belize"},
      {"code": "BJ", "name": "Benin"},
      {"code": "BM", "name": "Bermuda"},
      {"code": "BT", "name": "Bhutan"},
      {"code": "BO", "name": "Bolivia"},
      {"code": "BA", "name": "Bosnia and Herzegovina"},
      {"code": "BW", "name": "Botswana"},
      {"code": "BV", "name": "Bouvet Island"},
      {"code": "BR", "name": "Brazil"},
      {"code": "IO", "name": "British Indian Ocean Territory"},
      {"code": "VG", "name": "British Virgin Islands"},
      {"code": "BN", "name": "Brunei"},
      {"code": "BG", "name": "Bulgaria"},
      {"code": "BF", "name": "Burkina Faso"},
      {"code": "BI", "name": "Burundi"},
      {"code": "KH", "name": "Cambodia"},
      {"code": "CM", "name": "Cameroon"},
      {"code": "CA", "name": "Canada"},
      {"code": "CV", "name": "Cape Verde"},
      {"code": "BQ", "name": "Caribbean Netherlands"},
      {"code": "KY", "name": "Cayman Islands"},
      {"code": "CF", "name": "Central African Republic"},
      {"code": "TD", "name": "Chad"},
      {"code": "CL", "name": "Chile"},
      {"code": "CN", "name": "China"},
      {"code": "CX", "name": "Christmas Island"},
      {"code": "CC", "name": "Cocos (Keeling) Islands"},
      {"code": "CO", "name": "Colombia"},
      {"code": "KM", "name": "Comoros"},
      {"code": "CK", "name": "Cook Islands"},
      {"code": "CR", "name": "Costa Rica"},
      {"code": "CI", "name": "Côte d'Ivoire"},
      {"code": "HR", "name": "Croatia"},
      {"code": "CU", "name": "Cuba"},
      {"code": "CW", "name": "Curaçao"},
      {"code": "CY", "name": "Cyprus"},
      {"code": "CZ", "name": "Czech Republic"},
      {"code": "CD", "name": "Democratic Republic of the Congo"},
      {"code": "DK", "name": "Denmark"},
      {"code": "DJ", "name": "Djibouti"},
      {"code": "DM", "name": "Dominica"},
      {"code": "DO", "name": "Dominican Republic"},
      {"code": "EC", "name": "Ecuador"},
      {"code": "EG", "name": "Egypt"},
      {"code": "SV", "name": "El Salvador"},
      {"code": "GQ", "name": "Equatorial Guinea"},
      {"code": "ER", "name": "Eritrea"},
      {"code": "EE", "name": "Estonia"},
      {"code": "SZ", "name": "Eswatini"},
      {"code": "ET", "name": "Ethiopia"},
      {"code": "FK", "name": "Falkland Islands"},
      {"code": "FO", "name": "Faroe Islands"},
      {"code": "FJ", "name": "Fiji"},
      {"code": "FI", "name": "Finland"},
      {"code": "FR", "name": "France"},
      {"code": "GF", "name": "French Guiana"},
      {"code": "PF", "name": "French Polynesia"},
      {"code": "TF", "name": "French Southern Territories"},
      {"code": "GA", "name": "Gabon"},
      {"code": "GM", "name": "Gambia"},
      {"code": "GE", "name": "Georgia"},
      {"code": "DE", "name": "Germany"},
      {"code": "GH", "name": "Ghana"},
      {"code": "GI", "name": "Gibraltar"},
      {"code": "GR", "name": "Greece"},
      {"code": "GL", "name": "Greenland"},
      {"code": "GD", "name": "Grenada"},
      {"code": "GP", "name": "Guadeloupe"},
      {"code": "GU", "name": "Guam"},
      {"code": "GT", "name": "Guatemala"},
      {"code": "GG", "name": "Guernsey"},
      {"code": "GN", "name": "Guinea"},
      {"code": "GW", "name": "Guinea-Bissau"},
      {"code": "GY", "name": "Guyana"},
      {"code": "HT", "name": "Haiti"},
      {"code": "HM", "name": "Heard Island and McDonald Islands"},
      {"code": "HN", "name": "Honduras"},
      {"code": "HK", "name": "Hong Kong"},
      {"code": "HU", "name": "Hungary"},
      {"code": "IS", "name": "Iceland"},
      {"code": "IN", "name": "India"},
      {"code": "ID", "name": "Indonesia"},
      {"code": "IR", "name": "Iran"},
      {"code": "IQ", "name": "Iraq"},
      {"code": "IE", "name": "Ireland"},
      {"code": "IM", "name": "Isle of Man"},
      {"code": "IL", "name": "Israel"},
      {"code": "IT", "name": "Italy"},
      {"code": "JM", "name": "Jamaica"},
      {"code": "JP", "name": "Japan"},
      {"code": "JE", "name": "Jersey"},
      {"code": "JO", "name": "Jordan"},
      {"code": "KZ", "name": "Kazakhstan"},
      {"code": "KE", "name": "Kenya"},
      {"code": "KI", "name": "Kiribati"},
      {"code": "KW", "name": "Kuwait"},
      {"code": "KG", "name": "Kyrgyzstan"},
      {"code": "LA", "name": "Laos"},
      {"code": "LV", "name": "Latvia"},
      {"code": "LB", "name": "Lebanon"},
      {"code": "LS", "name": "Lesotho"},
      {"code": "LR", "name": "Liberia"},
      {"code": "LY", "name": "Libya"},
      {"code": "LI", "name": "Liechtenstein"},
      {"code": "LT", "name": "Lithuania"},
      {"code": "LU", "name": "Luxembourg"},
      {"code": "MO", "name": "Macao"},
      {"code": "MG", "name": "Madagascar"},
      {"code": "MW", "name": "Malawi"},
      {"code": "MY", "name": "Malaysia"},
      {"code": "MV", "name": "Maldives"},
      {"code": "ML", "name": "Mali"},
      {"code": "MT", "name": "Malta"},
      {"code": "MH", "name": "Marshall Islands"},
      {"code": "MQ", "name": "Martinique"},
      {"code": "MR", "name": "Mauritania"},
      {"code": "MU", "name": "Mauritius"},
      {"code": "YT", "name": "Mayotte"},
      {"code": "MX", "name": "Mexico"},
      {"code": "FM", "name": "Micronesia"},
      {"code": "MD", "name": "Moldova"},
      {"code": "MC", "name": "Monaco"},
      {"code": "MN", "name": "Mongolia"},
      {"code": "ME", "name": "Montenegro"},
      {"code": "MS", "name": "Montserrat"},
      {"code": "MA", "name": "Morocco"},
      {"code": "MZ", "name": "Mozambique"},
      {"code": "MM", "name": "Myanmar"},
      {"code": "NA", "name": "Namibia"},
      {"code": "NR", "name": "Nauru"},
      {"code": "NP", "name": "Nepal"},
      {"code": "NL", "name": "Netherlands"},
      {"code": "NC", "name": "New Caledonia"},
      {"code": "NZ", "name": "New Zealand"},
      {"code": "NI", "name": "Nicaragua"},
      {"code": "NE", "name": "Niger"},
      {"code": "NG", "name": "Nigeria"},
      {"code": "NU", "name": "Niue"},
      {"code": "NF", "name": "Norfolk Island"},
      {"code": "KP", "name": "North Korea"},
      {"code": "MK", "name": "North Macedonia"},
      {"code": "MP", "name": "Northern Mariana Islands"},
      {"code": "NO", "name": "Norway"},
      {"code": "OM", "name": "Oman"},
      {"code": "PK", "name": "Pakistan"},
      {"code": "PW", "name": "Palau"},
      {"code": "PS", "name": "Palestine"},
      {"code": "PA", "name": "Panama"},
      {"code": "PG", "name": "Papua New Guinea"},
      {"code": "PY", "name": "Paraguay"},
      {"code": "PE", "name": "Peru"},
      {"code": "PH", "name": "Philippines"},
      {"code": "PN", "name": "Pitcairn Islands"},
      {"code": "PL", "name": "Poland"},
      {"code": "PT", "name": "Portugal"},
      {"code": "PR", "name": "Puerto Rico"},
      {"code": "QA", "name": "Qatar"},
      {"code": "CG", "name": "Republic of the Congo"},
      {"code": "RE", "name": "Réunion"},
      {"code": "RO", "name": "Romania"},
      {"code": "RU", "name": "Russia"},
      {"code": "RW", "name": "Rwanda"},
      {"code": "BL", "name": "Saint Barthélemy"},
      {"code": "SH", "name": "Saint Helena"},
      {"code": "KN", "name": "Saint Kitts and Nevis"},
      {"code": "LC", "name": "Saint Lucia"},
      {"code": "MF", "name": "Saint Martin"},
      {"code": "PM", "name": "Saint Pierre and Miquelon"},
      {"code": "VC", "name": "Saint Vincent and the Grenadines"},
      {"code": "WS", "name": "Samoa"},
      {"code": "SM", "name": "San Marino"},
      {"code": "ST", "name": "São Tomé and Príncipe"},
      {"code": "SA", "name": "Saudi Arabia"},
      {"code": "SN", "name": "Senegal"},
      {"code": "RS", "name": "Serbia"},
      {"code": "SC", "name": "Seychelles"},
      {"code": "SL", "name": "Sierra Leone"},
      {"code": "SG", "name": "Singapore"},
      {"code": "SX", "name": "Sint Maarten"},
      {"code": "SK", "name": "Slovakia"},
      {"code": "SI", "name": "Slovenia"},
      {"code": "SB", "name": "Solomon Islands"},
      {"code": "SO", "name": "Somalia"},
      {"code": "ZA", "name": "South Africa"},
      {"code": "GS", "name": "South Georgia and the South Sandwich Islands"},
      {"code": "KR", "name": "South Korea"},
      {"code": "SS", "name": "South Sudan"},
      {"code": "ES", "name": "Spain"},
      {"code": "LK", "name": "Sri Lanka"},
      {"code": "SD", "name": "Sudan"},
      {"code": "SR", "name": "Suriname"},
      {"code": "SJ", "name": "Svalbard and Jan Mayen"},
      {"code": "SE", "name": "Sweden"},
      {"code": "CH", "name": "Switzerland"},
      {"code": "SY", "name": "Syria"},
      {"code": "TW", "name": "Taiwan"},
      {"code": "TJ", "name": "Tajikistan"},
      {"code": "TZ", "name": "Tanzania"},
      {"code": "TH", "name": "Thailand"},
      {"code": "TL", "name": "Timor-Leste"},
      {"code": "TG", "name": "Togo"},
      {"code": "TK", "name": "Tokelau"},
      {"code": "TO", "name": "Tonga"},
      {"code": "TT", "name": "Trinidad and Tobago"},
      {"code": "TN", "name": "Tunisia"},
      {"code": "TR", "name": "Turkey"},
      {"code": "TM", "name": "Turkmenistan"},
      {"code": "TC", "name": "Turks and Caicos Islands"},
      {"code": "TV", "name": "Tuvalu"},
      {"code": "UG", "name": "Uganda"},
      {"code": "UA", "name": "Ukraine"},
      {"code": "AE", "name": "United Arab Emirates"},
      {"code": "GB", "name": "United Kingdom"},
      {"code": "US", "name": "United States"},
      {"code": "UM", "name": "United States Minor Outlying Islands"},
      {"code": "VI", "name": "United States Virgin Islands"},
      {"code": "UY", "name": "Uruguay"},
      {"code": "UZ", "name": "Uzbekistan"},
      {"code": "VU", "name": "Vanuatu"},
      {"code": "VA", "name": "Vatican City"},
      {"code": "VE", "name": "Venezuela"},
      {"code": "VN", "name": "Vietnam"},
      {"code": "WF", "name": "Wallis and Futuna"},
      {"code": "EH", "name": "Western Sahara"},
      {"code": "YE", "name": "Yemen"},
      {"code": "ZM", "name": "Zambia"},
      {"code": "ZW", "name": "Zimbabwe"},
    ];
  }
}
