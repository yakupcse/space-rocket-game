# 🎮 Flutter + Flame Mobil Oyun Projesi

Bu proje Flutter ve Flame kullanılarak geliştirilmiş basit bir mobil oyundur.

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.0.0 veya üzeri)
- Android Studio veya VS Code
- Android SDK

### Adımlar

1. **Flutter SDK'yı kurun:**
   - [Flutter resmi sitesinden](https://docs.flutter.dev/get-started/install/windows) indirin
   - `C:\flutter` klasörüne çıkartın
   - Sistem PATH'ine `C:\flutter\bin` ekleyin

2. **Projeyi çalıştırın:**
   ```bash
   flutter pub get
   flutter run
   ```

## 🎯 Oyun Özellikleri

- **Mavi kare**: Oyuncu karakteri
- **Kırmızı kareler**: Düşmanlar
- **Dokunma kontrolü**: Ekrana dokunarak karakteri hareket ettirin
- **Skor sistemi**: Düşmanlardan kaçarak skor kazanın
- **Çarpışma algılama**: Düşmana çarparsanız oyun biter

## 🎮 Nasıl Oynanır

1. Ekrana dokunarak mavi karakteri hareket ettirin
2. Sağdan gelen kırmızı düşmanlardan kaçın
3. Düşmanlardan kaçtıkça skor kazanın
4. Düşmana çarparsanız oyun biter

## 📁 Proje Yapısı

```
lib/
├── main.dart              # Ana uygulama dosyası
└── game/
    ├── simple_game.dart   # Ana oyun sınıfı
    ├── player.dart        # Oyuncu karakteri
    └── enemy.dart         # Düşman karakteri
```

## 🔧 Geliştirme

Oyunu geliştirmek için:
1. `lib/game/` klasöründeki dosyaları düzenleyin
2. Yeni özellikler ekleyin
3. `flutter run` ile test edin

## 📱 Platform Desteği

- ✅ Android
- ✅ iOS (iOS simülatörü veya cihaz gerekli)
- ✅ Web (deneysel)

## 🎨 Özelleştirme

- Renkleri değiştirmek için `paint` özelliklerini düzenleyin
- Hızları ayarlamak için `speed` sabitlerini değiştirin
- Yeni karakterler eklemek için yeni component sınıfları oluşturun

İyi oyunlar! 🎮
