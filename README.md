# Saldoku - Aplikasi Manajemen Keuangan Pribadi

Saldoku adalah aplikasi manajemen keuangan pribadi berbasis Flutter yang membantu Anda mengelola keuangan dengan mudah dan terorganisir.

## ✨ Fitur Utama

### ✅ Sudah Diimplementasikan
- **Autentikasi**
  - Onboarding screen dengan 3 slides informatif
  - Login dengan email & password
  - Register akun baru dengan validasi
  
- **Dashboard Home**
  - Tampilan saldo total dari semua dompet
  - Ringkasan pemasukan & pengeluaran bulan ini
  - 8 Quick actions (Dompet, Tagihan, Tabungan, Investasi, Anggaran, Hutang, Kategori, Transfer)
  - Daftar transaksi terakhir
  - Notifikasi tagihan & anggaran

- **Profile & Settings**
  - Lihat & edit profil pengguna
  - Ganti password dengan validasi
  - **Pengaturan Tema** (Light/Dark/System)
  - Pengaturan mata uang (IDR, USD, EUR, GBP, JPY, SGD, MYR)
  - Pengaturan bahasa (Indonesia/English)
  - Toggle notifikasi & biometrik
  - Logout dengan konfirmasi

### 🚧 Dalam Pengembangan
- Manajemen Dompet (Wallet Management)
- Transaksi Harian (Daily Transactions)
- Kategori (Categories)
- Anggaran (Budget)
- Tagihan (Bills)
- Target Tabungan (Savings Goals)
- Investasi (Investments)
- Hutang & Piutang (Debts)
- Transfer Antar Dompet (Wallet Transfer)
- Laporan Keuangan (Financial Reports)

## 🎨 Desain & UI

- **Material Design 3** dengan komponen modern
- **Tema Light & Dark Mode** dengan smooth transition
- **Custom Widgets** yang reusable (CustomButton, CustomTextField, CustomCard, dll)
- **Typography Material You** dengan hierarki yang jelas
- **Color Scheme** konsisten dengan brand colors
- **Bottom Navigation** dengan Floating Action Button tengah
- **Responsive Layout** untuk berbagai ukuran layar

## 🗄️ Database & Storage

- **SQLite Database** dengan 11 tabel relasional:
  - users
  - wallets
  - transactions
  - categories
  - budgets
  - bills
  - savings_goals
  - investments
  - debts
  - wallet_transfers
  - notifications

- **SharedPreferences** untuk:
  - User session (user_id)
  - Theme mode (light/dark/system)
  - Onboarding status
  - Currency preference
  - Language preference
  - Notification & biometric settings

## 🏗️ Arsitektur

```
lib/
├── app/
│   ├── constants/       # App colors, text styles
│   ├── theme/          # AppTheme, ThemeExtensions
│   ├── widgets/        # Custom reusable widgets
│   └── router.dart     # App routing
├── core/
│   ├── db/             # Database & DAOs
│   ├── models/         # Data models
│   ├── services/       # Auth, Notification, SharedPrefs services
│   └── utils/          # Currency format, date utils
├── features/
│   ├── auth/           # Login, Register, Onboarding
│   ├── home/           # Dashboard
│   ├── profile/        # Profile, Settings, Change Password
│   └── ...             # Other features
└── main.dart
```

## 🚀 Cara Menjalankan

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd saldoku_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- **flutter_localizations** - Internationalization
- **intl** - Date & number formatting
- **sqflite** - SQLite database
- **path_provider** - File system paths
- **shared_preferences** - Key-value storage
- **Material 3** - Modern UI components

## 📱 Screenshot

(Coming soon)

## 🔐 Keamanan

- Password disimpan dalam plaintext (untuk development)
- **⚠️ PENTING**: Untuk production, gunakan hashing (bcrypt/argon2) untuk password
- Session management dengan SharedPreferences
- Opsi biometrik authentication (planned)

## 🌍 Bahasa

- 🇮🇩 Bahasa Indonesia (Default)
- 🇺🇸 English (Planned)

## 💰 Mata Uang Didukung

- IDR - Rupiah Indonesia (Default)
- USD - US Dollar
- EUR - Euro
- GBP - British Pound
- JPY - Japanese Yen
- SGD - Singapore Dollar
- MYR - Malaysian Ringgit

## 📝 License

MIT License

## 👨‍💻 Pengembang

Dikembangkan dengan ❤️ menggunakan Flutter

---

**Status**: 🟡 Development in Progress
**Version**: 0.1.0
**Flutter Version**: 3.7.2
