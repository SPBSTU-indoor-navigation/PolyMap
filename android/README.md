# PolyMap for Android

Android-порт iOS-приложения **PolyMap** (карта кампуса СПбПУ с планировками корпусов, поиском кабинетов,
маршрутами и приглашениями). Исходники iOS-версии: https://github.com/SPBSTU-indoor-navigation/PolyMap

Порт основан на исходниках Swift и использует данные карты IMDF из iOS-версии.
Реализованы поиск пути, экраны карты и навигационная шторка. Полное совпадение поведения
с iOS-версией пока не подтверждено; проверка на реальных устройствах приветствуется.

## Сборка

Два флейвора рендерера карты: `gl` (MapLibre `android-sdk-opengl`, OpenGL ES, рекомендуется) и `vulkan`
(`android-sdk-vulkan`). Внимание: артефакт `org.maplibre.gl:android-sdk` в 13.x — это Vulkan.

```bash
cd android
./gradlew :app:assembleGlDebug :app:assembleVulkanDebug
```

В debug-сборках при падении при следующем запуске показывается экран диагностики (Java-стек или системная причина смерти
процесса + tombstone), с кнопками «Поделиться» и «Без карты».

Нужны JDK 17+ и Android SDK (compileSdk 36). Путь к SDK — в `local.properties` (`sdk.dir=...`).

APK: `app/build/outputs/apk/gl/debug/app-gl-debug.apk` и
`app/build/outputs/apk/vulkan/debug/app-vulkan-debug.apk` (относительно папки `android/`).
Установка на телефон с включённой отладкой по USB:

```bash
adb install -r app/build/outputs/apk/gl/debug/app-gl-debug.apk
```

Юнит-тесты (декодер IMDF, поиск маршрута на реальных данных):

```bash
./gradlew :app:testGlDebugUnitTest :app:testVulkanDebugUnitTest
```

На Windows используйте `gradlew.bat` вместо `./gradlew`.

## Архитектура

| iOS                              | Android                                                        |
|----------------------------------|----------------------------------------------------------------|
| `IMDF/*` (модели, декодер)       | `imdf/` — `Models.kt`, `ImdfDecoder.kt`, `Geometry.kt`         |
| `PathFinder` (GameplayKit)       | `pathfinder/PathFinder.kt` — Дейкстра по графу navPath         |
| `MapView` (MapKit)               | `map/PolyMapView.kt` — MapLibre + `MapStyle.kt` (слои IMDF)    |
| `*AnnotationView`                | `map/annotations/views/*` — кастомные View с теми же анимациями |
| `LevelSwitcher`                  | `map/LevelSwitcher.kt`                                          |
| `BottomSheetViewController`      | `bottomsheet/BottomSheetContainer.kt` (3 положения, nested scroll) |
| `SearchVC`, `UnitDetailVC`, `RouteDetailVC`, `ExclusiveRouteDetailVC` | `pages/*` (RecyclerView)      |
| `MapInfo`                        | `pages/MapInfo.kt`                                              |
| SwiftUI-экраны (Share, Report, Hello, …) | `ui/screens/*` (Jetpack Compose, модальный лист)         |
| `TimetableVC`, `SettingTimetableVC` | `timetable/*` (Compose)                                      |
| `TimetableProvider`, `CodeGeneratorProvider`, `ReportApiProvider` | `api/*` (OkHttp + Gson)        |
| `UserDefaults`-хранилища         | `storage/Storage.kt`                                            |

Подложка карты — векторные стили OpenFreeMap (bright / fiord), запасной вариант — растровые тайлы OSM, внутри кампуса всё отрисовано из IMDF-слоёв
как в iOS (цвета из `Assets.xcassets` перенесены в `res/values(-night)/colors_ios.xml`).
Уровни зума пересчитаны: `iOS zoom = MapLibre zoom + 2`.

Deep links (`https://polymap.ru/share/route`, `/share/annotation`, `/l/<id>`) обрабатываются в `MainActivity`.
Сервер `polymap.ru` (генерация QR/AppClip-кодов, отчёты об ошибках) — тот же, что и у iOS-версии.
