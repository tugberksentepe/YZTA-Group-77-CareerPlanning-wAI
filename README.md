# YZTA-Group-77 AI Destekli Kariyer Planlama Projesi

Bu proje, yapay zeka destekli bir kariyer planlama sistemi içerir. Kullanıcıların sorulara verdikleri cevaplara göre kişiselleştirilmiş kariyer planları oluşturur ve yapay zeka ile kariyer planı üzerinde sohbet etmelerini sağlar.

## Proje Yapısı

Proje iki ana bölümden oluşmaktadır:

1. `app/` - Python/FastAPI ile yazılmış backend API
2. `flutter_client/` - Flutter ile yazılmış mobil uygulama

## Backend API (FastAPI)

FastAPI tabanlı backend, aşağıdaki özelliklere sahiptir:

- Dinamik AI destekli anket sistemi (10 soru)
- Kişiselleştirilmiş kariyer planı oluşturma
- AI ile sohbet arayüzü
- Asenkron veri işleme
- SQLite veritabanı ile veri saklama

Backend projenin detayları için [app/README.md](app/README.md) dosyasına bakabilirsiniz.

## Mobil Uygulama (Flutter)

Flutter tabanlı mobil uygulama, backend API ile entegre çalışarak kullanıcılara aşağıdaki özellikleri sunar:

- Kullanıcıya özgü dinamik anket soruları
- Yapay zeka destekli kişiselleştirilmiş kariyer planı görüntüleme
- Kariyer planı hakkında yapay zeka ile sohbet edebilme
- Güzel ve kullanıcı dostu arayüz

Mobil uygulama detayları için [flutter_client/README.md](flutter_client/README.md) dosyasına bakabilirsiniz.

## Kurulum ve Çalıştırma

### Gereksinimler

- Python 3.9 veya üstü
- Flutter SDK 3.0.0 veya üstü
- Google AI API anahtarı (Gemini API)

### Backend API Kurulumu

1. Gerekli Python paketlerini yükleyin:
```bash
pip install -r requirements.txt
```

2. `.env` dosyasını oluşturun:
```
GOOGLE_API_KEY=your_gemini_api_key_here
DATABASE_URL=sqlite:///./career_planner.db
```

3. API'yi başlatın:
```bash
uvicorn main:app --reload
```

API varsayılan olarak http://localhost:8000 adresinde çalışacaktır.

### Flutter Uygulaması Kurulumu

1. Flutter bağımlılıklarını yükleyin:
```bash
cd flutter_client
flutter pub get
```

2. `.env` dosyasını oluşturun:
```
API_BASE_URL=http://localhost:8000
EMAIL=test@example.com
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## Ekip İçin Notlar

### Backend Geliştiricileri İçin
- FastAPI ve SQL Alchemy ile veritabanı işlemleri `app/database/` klasöründe
- Gemini API entegrasyonu `app/services/` klasöründe
- API endpoint'leri `app/routers/` klasöründe
- Veri modelleri `app/schemas/` klasöründe 

### Mobil Geliştiricileri İçin
- API iletişimi ve state yönetimi `flutter_client/lib/services/` klasöründe
- Ekranlar `flutter_client/lib/screens/` klasöründe
- Veri modelleri `flutter_client/lib/models/` klasöründe
- UI bileşenleri `flutter_client/lib/widgets/` klasöründe (eklenebilir)
