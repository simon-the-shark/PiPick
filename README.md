# PiPick 
Projekt PiPick to edukacyjny proof of concept strefowego systemu zarządzania dostępem

## Instrukcja odpalenia
Aby projekt w pełni funckjonował, naley uruchomić nastepujące elementy

1. Panel admina we Flutterze
2. Kod na rasberry pi
3. Brokera MQTT


### Uruchomienie panelu admina we Flutterze
1. Opcja 1 - gotowa binarka
Jeśli urządzeniem docelowym jest windows, można skorzystać z gotowych binarek zbudowanych na Github Actions albo pobrać wersję z Microsoft Store

2. Opcja 2 - budowana DIY
Aby zbudować aplikację desktopową, nalezy
    1. Zainstalować Fluttera i Darta według oficjalnych instrukcji: https://docs.flutter.dev/get-started/install
    2. Zainstalować paczki: `flutter pub get`
    3. Wygenerować brakujące pliki: `dart run build_runner build -d`
    4. Uruchomić: `flutter run`

### Uruchomienie innych rzeczy