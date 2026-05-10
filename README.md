# 💰 DivideCuenta — App Flutter

App para dividir cuentas entre amigos en pesos mexicanos (MXN).

---

## Cómo correr el proyecto

### Requisitos
- Flutter instalado (https://flutter.dev/docs/get-started/install)
- Un editor: VS Code o Android Studio

### Pasos

```bash
# 1. Entra a la carpeta del proyecto
cd dividecuenta

# 2. Descarga las dependencias
flutter pub get

# 3. Corre la app (con un emulador o dispositivo conectado)
flutter run
```

---

## Activar el botón de WhatsApp

1. Abre `pubspec.yaml`
2. Descomenta la línea: `url_launcher: ^6.2.5`
3. Corre `flutter pub get`
4. En `main.dart`, busca el botón de WhatsApp y reemplaza el `onPressed` con esto:

```dart
onPressed: () async {
  final url = 'https://wa.me/?text=${_textoWhatsApp()}';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
},
```

5. Agrega el import arriba del archivo:
```dart
import 'package:url_launcher/url_launcher.dart';
```

---

## Estructura del código

```
lib/
  main.dart          ← Todo el código en un solo archivo
    ├── DivideCuentaApp       (configuración de tema y colores)
    ├── PantallaPrincipal     (pantalla 1: entrada de datos)
    │     ├── _VistaIgual     (modo división igual)
    │     ├── _VistaPorcentaje (modo por porcentaje)
    │     └── _VistaManual    (modo montos manuales)
    └── PantallaResultados    (pantalla 2: resultados)
```

---

## Funcionalidades

- ✅ Ingresar total de la cuenta
- ✅ Agregar/eliminar participantes con chips
- ✅ Tres modos de división: igual, por porcentaje, manual
- ✅ Barra de progreso visual por persona
- ✅ Copiar resumen al portapapeles
- ⚙️ Compartir por WhatsApp (requiere url_launcher)
