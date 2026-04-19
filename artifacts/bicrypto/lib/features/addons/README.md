# BiCrypto Addons

This directory contains all the addon features for BiCrypto mobile app following Clean Architecture principles.

## Available Addons

1. P2P Trading (`p2p/`)
2. Blog/News (`blog/`)
3. E-commerce (`ecommerce/`)
4. AI Investment (`ai_investment/`)
5. ICO/Token Launch (`ico/`)
6. Forex Trading (`forex/`)
7. Futures Trading (`futures/`)
8. Staking (`staking/`)
9. Ecosystem (`ecosystem/`)
10. MailWizard (`mailwizard/`)

## Folder Structure

Each addon follows Clean Architecture with the following structure:

```
addon_name/
├── data/
│   ├── datasources/       # API and local data sources
│   ├── models/           # Data models with JSON serialization
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/        # Business logic use cases
└── presentation/
    ├── bloc/            # BLoC state management
    ├── pages/           # Screen/page widgets
    └── widgets/         # Feature-specific widgets
``` 