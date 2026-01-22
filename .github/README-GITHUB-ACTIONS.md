# GitHub Actions - Build APK

Workflow file telah dibuat untuk build APK secara otomatis menggunakan GitHub Actions.

## 📁 File Location
`.github/workflows/build-apk.yml`

## 🚀 Cara Menggunakan

### Option 1: Push ke Repository
```bash
git add .github/workflows/build-apk.yml
git commit -m "Add GitHub Actions workflow for APK build"
git push origin main  # atau branch yang Anda gunakan
```

### Option 2: Manual Trigger
1. Buka repository di GitHub
2. Klik tab **Actions**
3. Pilih workflow **Build Flutter APK**
4. Klik **Run workflow**

## 📦 Output

Setelah workflow selesai, Anda dapat download APK dari:
1. Buka tab **Actions** di GitHub
2. Klik pada workflow run yang sukses
3. Scroll ke bawah ke bagian **Artifacts**
4. Download **apk-builds** (berisi semua variant APK)

## 📋 APK Variants

Workflow akan menghasilkan:
- **app-armeabi-v7a-release.apk** (untuk device 32-bit lama)
- **app-arm64-v8a-release.apk** (untuk device 64-bit modern) ⭐ **Gunakan ini untuk kebanyakan device**
- **app-x86_64-release.apk** (untuk emulator/device x86)
- **app-release.apk** (universal - semua arsitektur)

## ⚙️ Konfigurasi

Jika perlu, sesuaikan di file workflow:
- **Flutter Version**: Line 23 (`flutter-version: '3.24.0'`)
- **Trigger Branches**: Line 4-6 (branches yang memicu build)

## 🔧 Troubleshooting

Jika build gagal:
1. Pastikan `pubspec.yaml` sudah benar
2. Cek error di tab Actions > workflow run yang gagal
3. Sesuaikan Flutter version jika perlu
