# HarmonyShare

<!-- HarmonyShare 是一个用于HarmonyOS 的LocalSend适配 -->
HarmonyShare is an adaptation of LocalSend for HarmonyOS Next.  

# LocalSend

[![CI status][ci-badge]][ci-workflow]
[![Translations][translate-badge]][translate-link]
[![Packaging status][packaging-badge]][packaging-link]

[ci-badge]: https://github.com/localsend/localsend/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/localsend/localsend/actions/workflows/ci.yml
[translate-badge]: https://hosted.weblate.org/widget/localsend/app/svg-badge.svg
[translate-link]: https://hosted.weblate.org/engage/localsend/
[packaging-badge]: https://repology.org/badge/tiny-repos/localsend.svg
[packaging-link]: https://repology.org/project/localsend/versions

[Homepage][homepage] • [Discord][discord] • [GitHub][github] • [Codeberg][codeberg]

[English (Default)](README.md) • [Español](readme_i18n/README_ES.md) • [فارسی](readme_i18n/README_FA.md) • [Filipino](readme_i18n/README_PH.md) • [Français](readme_i18n/README_FR.md) • [Indonesia](readme_i18n/README_ID.md) • [Italiano](readme_i18n/README_IT.md) • [日本語](readme_i18n/README_JA.md) • [ភាសាខ្មែរ](readme_i18n/README_KM.md) • [한국어](readme_i18n/README_KO.md) • [Polski](readme_i18n/README_PL.md) • [Portugês Brasil](readme_i18n/README_PT_BR.md) • [Русский](readme_i18n/README_RU.md) • [ภาษาไทย](readme_i18n/README_TH.md) • [Türkçe](readme_i18n/README_TR.md) • [Українська](readme_i18n/README_UK.md) • [Tiếng Việt](readme_i18n/README_VI.md) • [中文](readme_i18n/README_ZH.md)

[homepage]: https://localsend.org
[discord]: https://discord.gg/GSRWmQNP87
[github]: https://github.com/localsend/localsend
[codeberg]: https://codeberg.org/localsend/localsend

LocalSend is a free, open-source app that allows you to securely share files and messages with nearby devices over your local network without needing an internet connection.

## About

LocalSend is a cross-platform app that enables secure communication between devices using a REST API and HTTPS encryption. Unlike other messaging apps that rely on external servers, LocalSend doesn't require an internet connection or third-party servers, making it a fast and reliable solution for local communication.

## How It Works

LocalSend uses a secure communication protocol that allows devices to communicate with each other using a REST API. All data is sent securely over HTTPS, and the TLS/SSL certificate is generated on the fly on each device, ensuring maximum security.

For more information on the LocalSend Protocol, see the [documentation](https://github.com/localsend/protocol).

## Getting Started

To compile LocalSend from the source code, follow these steps:

1. Install Flutter [directly](https://flutter.dev) or using [fvm](https://fvm.app) (see [version required](.fvmrc))
2. Install [Rust](https://www.rust-lang.org/tools/install)
3. Clone the `LocalSend` repository
4. Run `cd app` to enter the app directory
5. Run `flutter pub get` to download dependencies
6. Run `flutter run` to start the app

> [!NOTE]
> LocalSend currently requires an older Flutter version (specified in [.fvmrc](.fvmrc))
> and thus build issues may be caused by a mismatch between the required and the (system-wide) installed Flutter version.  
> To make development more consistent, LocalSend uses [fvm](https://fvm.app) to manage the project Flutter version.
> After installing `fvm`, run `fvm flutter` instead of `flutter`.
