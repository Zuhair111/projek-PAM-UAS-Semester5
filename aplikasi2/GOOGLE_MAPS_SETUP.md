# Google Maps Setup Instructions

## Cara Mendapatkan Google Maps API Key

1. **Buka Google Cloud Console**
   - Kunjungi: https://console.cloud.google.com/

2. **Buat Project Baru** (atau gunakan yang sudah ada)
   - Klik "Select a Project" di bagian atas
   - Klik "NEW PROJECT"
   - Beri nama project (contoh: "Aplikasi2")
   - Klik "CREATE"

3. **Enable Google Maps SDK**
   - Di menu navigasi, pilih "APIs & Services" > "Library"
   - Cari "Maps SDK for Android"
   - Klik dan pilih "ENABLE"

4. **Buat API Key**
   - Di menu navigasi, pilih "APIs & Services" > "Credentials"
   - Klik "CREATE CREDENTIALS" > "API key"
   - Copy API key yang dihasilkan

5. **Masukkan API Key ke Aplikasi**
   - Buka file: `android/app/src/main/AndroidManifest.xml`
   - Ganti `YOUR_API_KEY_HERE` dengan API key Anda:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSy..."/> <!-- Paste API key Anda di sini -->
   ```

6. **Restrict API Key (Opsional tapi Direkomendasikan)**
   - Kembali ke Credentials page
   - Klik pada API key yang baru dibuat
   - Di "Application restrictions", pilih "Android apps"
   - Klik "ADD AN ITEM"
   - Untuk mendapatkan SHA-1 fingerprint, jalankan:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   - Masukkan package name: `com.example.aplikasi2`
   - Masukkan SHA-1 fingerprint dari hasil command di atas
   - Klik "SAVE"

## Testing

Setelah setup selesai, jalankan aplikasi:
```bash
flutter run
```

## Catatan Penting

- **API Key harus disimpan dengan aman!** Jangan commit ke public repository
- Gunakan environment variables atau file konfigurasi terpisah untuk production
- Free tier Google Maps memberikan $200 kredit per bulan
- Jika tidak ingin menggunakan Google Maps API Key, Anda bisa menggunakan alternatif seperti OpenStreetMap dengan package `flutter_map`

## Alternatif: Menggunakan Flutter Map (Tanpa API Key)

Jika ingin menggunakan peta gratis tanpa API key:

1. Update `pubspec.yaml`:
```yaml
dependencies:
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
```

2. Ganti implementasi di `location_page.dart` menggunakan Flutter Map

## Troubleshooting

### Map tidak muncul / tampil abu-abu
- Pastikan API key sudah benar
- Pastikan billing sudah diaktifkan di Google Cloud Console
- Pastikan Maps SDK for Android sudah di-enable
- Check logcat untuk error messages: `flutter logs`

### Permission denied
- Pastikan permissions sudah ditambahkan di AndroidManifest.xml
- Request runtime permissions di aplikasi

Untuk pertanyaan lebih lanjut, hubungi developer atau lihat dokumentasi:
- https://pub.dev/packages/google_maps_flutter
- https://developers.google.com/maps/documentation
