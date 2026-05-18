# Nabdh Alyanam (نبض اليمن)

Application of blood donation, developed using Flutter.

Data is fetched from the REST API (`https://nabdh.telqaia.com/api/v1`). Internet is required for most features; location lists are cached locally (Drift).

Migration plans: [`docs/restructure/README.md`](docs/restructure/README.md)

**For developers:** [`docs/developer-guide.md`](docs/developer-guide.md) — local vs production API, debug logging, run commands.

<img src="https://github.com/Ezzalarab/nabdh_alyaman/blob/master/screenshots/main_view.png">

<div align="center">

[![Open Source Love svg1](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](#)
[![GitHub Forks](https://img.shields.io/github/forks/saadhaxxan/Car_Game_Python_Pygame.svg?style=social&label=Fork&maxAge=2592000)](https://github.com/m-hamzashakeel/The_Holy_Quran_App/fork)
[![GitHub Issues](https://img.shields.io/github/issues/saadhaxxan/Car_Game_Python_Pygame.svg?style=flat&label=Issues&maxAge=2592000)](https://github.com/m-hamzashakeel/The_Holy_Quran_App/issues)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat&label=Contributions&colorA=red&colorB=black	)](#)

</div>

## ⬇️ Download Now

Get it from <a href="https://play.google.com/store/apps/details?id=com.ezzcode.nabdh_alyaman">Play Store</a>

## 💻 Installation steps

- Flutter SDK compatible with Dart `^3.8.1` (see `pubspec.yaml`)
- iOS FCM setup: [`docs/ios-firebase-setup.md`](docs/ios-firebase-setup.md)

Open a terminal in the project directory and run:

```
git clone https://github.com/Ezzalarab/nabdh_alyaman.git
cd nabdh_alyaman
flutter packages get
flutter run
```

Local backend (Android emulator):

```
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

## 📱 Screen Shots

<img src="https://github.com/Ezzalarab/nabdh_alyaman/blob/master/screenshots/image1.jpeg" width=180> <img src="https://github.com/Ezzalarab/nabdh_alyaman/blob/master/screenshots/image2.jpeg" width=180> <img src="https://github.com/Ezzalarab/nabdh_alyaman/blob/master/screenshots/image3.jpeg" width=180> <img src="https://github.com/Ezzalarab/nabdh_alyaman/blob/master/screenshots/image4.jpeg" width=180>
<img src="https://github.com/Ezzalarab/nabdh_alyaman/blob/master/screenshots/image5.jpeg" width=180>


## 🎯 Features

✅ All Governorates and Districts of Yemen

✅ Show compatible blood types

✅ Google Maps show

✅ Show nearby centers with their storage of blood


## 👨‍💻 Authors

### Ezzalarab
[![LinkedIn Link](https://img.shields.io/badge/Connect-Ezzalarab-blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/ezz-dev)

[![GitHub Follow](https://img.shields.io/badge/Connect-Ezzalarab-blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/Ezzalarab)

---

### TayebAlameri
[![LinkedIn Link](https://img.shields.io/badge/Connect-TayebAlameri-blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/altayeb-alameri)

[![GitHub Follow](https://img.shields.io/badge/Connect-TayebAlameri-blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/TayebAlameri)

---
If you liked the repo then kindly support it by giving it a star ⭐!

Copyright (c) 2023 ezzcode.com
