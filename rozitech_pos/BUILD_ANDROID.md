# Panduan Build Android - CASIR POS

Dokumentasi ini menjelaskan langkah-langkah untuk melakukan build aplikasi CASIR POS ke format Android Package (APK).

---

## 📋 Prasyarat Sistem

Sebelum melakukan build, pastikan perangkat Anda telah terinstal tools berikut:
1. **Flutter SDK**: Versi `3.22.x` or lebih baru.
2. **Java Development Kit (JDK)**: Versi JDK 17 (direkomendasikan) atau JDK 21.
3. **Android SDK & Build Tools**:
   * Compile SDK: Versi `36` (dikonfigurasi secara dinamis untuk subproject plugin).
   * Target SDK: Versi `34`.
   * Minimum SDK: Versi `21`.

---

## ⚙️ Konfigurasi Awal (Sebelum Build)

### 1. File `local.properties`
Pastikan path SDK Flutter dan Android terisi dengan benar di file `android/local.properties`. Contoh isi file:
```properties
sdk.dir=C\:\\Users\\NamaUser\\AppData\\Local\\Android\\Sdk
flutter.sdk=C\:\\flutter
```

### 2. File `key.properties` (Opsional - Untuk signing kunci release resmi)
Jika Anda menggunakan keystore kustom untuk ditandatangani secara aman, buat file `android/key.properties`:
```properties
storePassword=password_keystore_anda
keyPassword=password_kunci_anda
keyAlias=alias_kunci_anda
storeFile=path/ke/file/keystore.jks
```

---

## 🚀 Perintah Build APK

Buka terminal di root direktori `/rozitech_pos` lalu jalankan perintah berikut:

### 1. Bersihkan Cache Build Sebelumnya
```bash
flutter clean
```

### 2. Unduh Dependensi Terbaru
```bash
flutter pub get
```

### 3. Jalankan Generator Code (Drift Database)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Hentikan Daemon Gradle yang Berjalan (Untuk menghindari konflik port / locking)
```bash
cd android
./gradlew --stop
cd ..
```

### 5. Build APK Release (Produksi)
Jalankan perintah ini untuk memproduksi berkas APK release final:
```bash
flutter build apk --release
```
*Hasil output berkas APK akan tersimpan di:* `build/app/outputs/flutter-apk/app-release.apk`

---

## 🛠️ Penyelesaian Masalah (Troubleshooting) & Fitur Otomatisasi Build

Selama proses migrasi dan penyusunan build produksi, beberapa pembaharuan arsitektur Gradle telah diintegrasikan secara otomatis di proyek ini:

### 1. Error Manifest "package attribute is no longer supported"
Jika Anda menemukan error manifest di plugin seperti `blue_thermal_printer` karena kebijakan Android Gradle Plugin (AGP) 8.x:
* **Solusi Otomatis:** File `android/build.gradle.kts` telah ditambahkan konfigurasi pembersihan manifes otomatis saat proses evaluasi Gradle. Skrip ini menghapus atribut `package` yang usang pada file manifes dependensi secara otomatis sebelum kompilasi berjalan.

### 2. Error Versi Gradle "requires Android Gradle plugin 8.9.1 or higher"
Jika dependensi `androidx` versi terbaru menuntut versi compiler AGP yang lebih tinggi:
* **Solusi Otomatis:** Kami telah meningkatkan versi **Android Gradle Plugin (AGP)** menjadi `8.9.1` dan **Kotlin Gradle Plugin (KGP)** ke `2.2.20` di `android/settings.gradle.kts`.

### 3. Konflik Library Printer & Gambar
* Modul printer telah sepenuhnya dimigrasikan dari `esc_pos_utils` ke `esc_pos_utils_plus` untuk kompatibilitas penuh dengan pustaka manipulasi gambar modern (`image 4.x+`).

---

## 📲 Pengiriman APK ke Laravel Backend

Setelah build berhasil, Anda dapat menyalin file APK ke folder publik web Laravel agar member dapat mengunduhnya langsung melalui portal:
* **Lokasi Sumber:** `rozitech_pos/build/app/outputs/flutter-apk/app-release.apk`
* **Lokasi Tujuan:** `Company-Profile-Rozitech-main/public/downloads/casir_pos.apk`
