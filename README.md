# ⚡ Özüňi Syna — Quiz Platformasy

> Türkmen dilinde professional quiz platformasy. Android Flutter klient.

---

## 📋 Mazmuny

- [Taslama barada](#taslama-barada)
- [Ekranköpler we aýratynlyklar](#aýratynlyklar)
- [Tehniki stack](#tehniki-stack)
- [Taslamanyň gurluşy](#taslamanyň-gurluşy)
- [Başlatmak](#başlatmak)
  - [Flutter Android](#2-flutter-android)
- [API gollanmasy](#api-gollanmasy)
- [Skrinshotlar](#skrinshotlar)
- [Kynçylyklar we çözgütler](#kynçylyklar-we-çözgütler)

---

## 📱 Taslama barada

**Özüňi Syna** — Android telefonlar üçin döredilen interaktiw quiz programmasydyr. Ulanyjy öz adyny girizmeli, soňra dürli temalar boýunça quizleri saýlap, soraglara jogap bermeli. Netijede öz skory we liderler tablisasynda ýeri görünýär.


### Esasy maksatlar

- 🎓 Bilim derejesini ölçemek
- 🏆 Liderler tablisasy arkaly bäsdeşlik
- 📊 Öz öňe gidişiňi görkezýän statistika

---

## ✨ Aýratynlyklar

### Android Klient
| Aýratynlyk | Düşündiriş |
|------------|-----------|
| 🎬 Animasion splash ekran | Programmanyň açylyşynda owadan animasiýa |
| 👤 At giriziş | Oýunçy adyny bir gezek girizýär, ýatda saklanýar |
| 📋 Quiz sanawy | Serverden real-wagt ýüklenen quizler |
| ❓ Sorag ekrany | Progress bar, awto-geçiş, jogap tassyklamasy |
| 🏆 Netije ekrany | Skor, göterim, liderler tablisasy |
| 🌙 Dark tema | Cyberpunk stilinde garaňky dizaýn |
| 💾 Lokal ýat | SharedPreferences bilen at saklanýar |

---

## 🛠 Tehniki Stack

```
┌─────────────────────────────────────────┐
│           ANDROID KLIENT                │
│  Flutter 3.x  •  Dart 3.x              │
│  Google Fonts  •  SharedPreferences     │
│  http package  •  Material 3           │
└──────────────────┬──────────────────────┘
                   │ REST API (JSON)
                   │ HTTP
┌──────────────────▼──────────────────────┐
│           FLASK BACKEND                 │
│  Python Flask 3.0  •  SQLite           │
│  Flask-SQLAlchemy  •  Flask-CORS       │
│  Jinja2 Templates  •  SHA-256          │
└─────────────────────────────────────────┘
```

| Bölüm | Tehnologiýa | Version |
|-------|------------|---------|
| Android | Flutter + Dart | 3.35+ |
| Şriftler | Google Fonts (Syne + DM Sans) | — |

---

## 📁 Taslamanyň gurluşy

```
ozuni_syna/
│
└── 📂 flutter_app/                 ← Android klient
    ├── pubspec.yaml                ← Flutter baglylyklarý
    └── 📂 lib/
        ├── main.dart               ← Programma başlangyç nokady
        ├── 📂 theme/
        │   └── app_theme.dart      ← Reňkler, tema sazlamalary
        ├── 📂 models/
        │   └── models.dart         ← Quiz, Question, Result modelleri
        ├── 📂 services/
        │   └── api_service.dart    ← HTTP API çagyryşlary
        └── 📂 screens/
            ├── splash_screen.dart      ← Açylyş ekrany
            ├── name_entry_screen.dart  ← At giriziş ekrany
            ├── quiz_list_screen.dart   ← Quiz sanawy
            ├── quiz_screen.dart        ← Sorag çözüş ekrany
            └── result_screen.dart      ← Netije + liderler
```

---

## 🚀 Başlatmak

### Talaplar

**Flutter üçin:**
- Flutter 3.0 ýa-da has täze
- Android Studio ýa-da VS Code
- Android enjam ýa-da emulator (API 21+)

---

### 2. Flutter Android

#### IP adresini sazlamak

`lib/services/api_service.dart` faýlyny açyň:

```dart
class ApiService {
  // Android Emulator üçin:
  static const String baseUrl = 'http://10.0.2.2:5000';

  // Real Android enjam üçin (WiFi LAN):
  // static const String baseUrl = 'http://192.168.1.XXX:5000';
}
```

#### Gurmak we işletmek

```bash
cd ozuni_syna/flutter_app

# Platform faýllaryny döretiň (bir gezek)
flutter create . --platforms=android

# Baglylyklarý ýükläň
flutter pub get

# Telefonyňyzda USB Debugging açyk bolsun
# Soňra:
flutter run
```

#### APK gurmak (paýlamak üçin)

```bash
flutter build apk --release
```

APK ýoly: `build/app/outputs/flutter-apk/app-release.apk`

#### USB Debugging açmak (Samsung)
1. **Sazlamalar** → **Telefon barada** → **Gurluş belgisi** → 7 gezek bas
2. **Sazlamalar** → **Geliştirici seçenekleri** → **USB hata ayıklama** → ON
3. USB bilen PC-a birikdir → "Rugsat ber" bas

---

## 🔌 API Gollanmasy

### GET `/api/quizzes`
Ähli quizleriň sanawyny gaýtarýar.

**Jogap:**
```json
[
  {
    "id": 1,
    "title": "Flutter Soraglary",
    "description": "Flutter framework barada esasy soraglar",
    "question_count": 5
  }
]
```

---

### GET `/api/quiz/<id>`
Bir quiziň ähli soraglary bilen maglumatyny gaýtarýar.

**Jogap:**
```json
{
  "id": 1,
  "title": "Flutter Soraglary",
  "description": "...",
  "questions": [
    {
      "id": 1,
      "question_text": "Flutter haýsy dil bilen ýazylýar?",
      "option_a": "Java",
      "option_b": "Kotlin",
      "option_c": "Dart",
      "option_d": "Swift"
    }
  ]
}
```

> ⚠️ Dogry jogaplar API-da görkezilmeýär — diňe netije iberilende server tarapyndan barlanýar.

---

### POST `/api/submit`
Quiz netijelerini iberýär we skory hasaplaýar.

**Sorag (Request body):**
```json
{
  "player_name": "Merdan",
  "quiz_id": 1,
  "answers": {
    "1": "C",
    "2": "B",
    "3": "D",
    "4": "C",
    "5": "B"
  }
}
```

**Jogap:**
```json
{
  "score": 4,
  "total": 5,
  "percentage": 80.0,
  "message": "Gutlaýarys, Merdan! 4/5 dogry jogap berdiňiz."
}
```

---

### GET `/api/leaderboard/<quiz_id>`
Bir quiz boýunça iň gowy 10 oýunçyny gaýtarýar.

**Jogap:**
```json
[
  {
    "rank": 1,
    "player_name": "Merdan",
    "score": 5,
    "total": 5,
    "percentage": 100.0
  }
]
```

---

## 🗄 Baza modelleri

```
Admin          Quiz           Question        Result
─────────      ──────────     ────────────    ──────────────
id             id             id              id
username       title          quiz_id (FK)    player_name
password       description    question_text   quiz_id (FK)
               created_at     option_a        score
                              option_b        total
                              option_c        percentage
                              option_d        completed_at
                              correct_answer
```

---

## 🔧 Kynçylyklar we çözgütler

### "Connection refused" ýalňyşlygy (Flutter)
```
Sebäp: IP adres ýalňyş ýazylgy
Çözgüt: api_service.dart-da baseUrl-y düzeliň
  - Emulator: http://10.0.2.2:5000
  - Real enjam: http://192.168.X.X:5000
```

### "No supported devices" (Flutter)
```
Sebäp: android/ gazasy ýok
Çözgüt: flutter create . --platforms=android
```

### Gradle build ýalňyşlygy
```
Sebäp: Gradle internete girip bilmeýär ýa-da versiýa gabat gelmeýär
Çözgüt:
  1. gradle-wrapper.properties-de distributionUrl-y barlaň
  2. Lokal gradle zip bar bolsa, file:/// ýoly bilen görkeziň
  3. flutter clean → flutter run
```

---

## 📦 Taslama baglylyklarý

### Flutter (flutter_app/pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
```

---

## 👨‍💻 Dörediji

**Merdan Ysmayylow** — Oguz Han Inžener adyndaky we Tehnologiýa Uniwersiteti, Türkmenistan Ashgabat

---

## 📄 Ygtyýarnama

Bu taslama okuw we diplom maksatlary üçin döredildi.

---

*⚡ Özüňi Syna — Bilim Quiz Platformasy · Türkmenistan*