# NeoDesk para Android

NeoDesk se distribuye para Android como un único archivo `.apk` en las
[Releases del repositorio](https://github.com/Amadosixteen/NeoDesk/releases). No está en
Play Store. No hay versión para iPhone/iPad.

## Qué se puede hacer

| Desde → hacia | ¿Funciona? |
|---|---|
| PC → teléfono Android | Sí |
| Teléfono Android → PC | Sí |
| Teléfono Android → teléfono Android | Sí |

## Qué teléfonos sirven

| Requisito | Para qué |
|---|---|
| Procesador y sistema de **64 bits (arm64-v8a)** | Para poder instalar el APK. Sin esto, no se instala. |
| Android 5.1 o superior | Para usar el teléfono para **controlar** otro equipo. |
| Android 7 o superior | Para que el teléfono pueda **ser controlado** (ver pantalla y tocar). |
| Android 11 o superior | Para transmitir también el **audio** del teléfono. |

### Teléfonos que NO sirven

- **Teléfonos con sistema de 32 bits.** Suele pasar en gamas de entrada y en muchos
  equipos con **Android Go** (los de 1–2 GB de RAM): aunque el procesador sea de 64 bits,
  el fabricante instala un Android de 32 bits. NeoDesk no se puede instalar en ellos;
  Android muestra "La app no es compatible" o "No se instaló la app".
- **Teléfonos con procesador Intel/x86** (muy raros, algunos modelos antiguos de 2014–2016).
- **Android 6 o inferior** para ser controlado: se puede instalar y usar para controlar
  una PC, pero no para que otro controle el teléfono.

### Cómo comprobar un teléfono antes de instalar

1. Instalar desde Play Store una app de información del sistema, por ejemplo
   **CPU-Z** o **AIDA64**.
2. Buscar el apartado **"Supported ABIs"** / **"ABIs compatibles"**.
3. Si en la lista aparece **`arm64-v8a`**, el teléfono sirve. Si solo aparecen
   `armeabi-v7a` / `armeabi`, no sirve.

La versión de Android se ve en *Ajustes → Acerca del teléfono → Versión de Android*.

## Instalación

1. Descargar `neodesk-<versión>-aarch64.apk` desde Releases, en el propio teléfono.
2. Abrir el archivo. Android pedirá permitir **instalar apps de origen desconocido** para
   el navegador o el gestor de archivos: aceptar y volver atrás.
3. Pulsar **Instalar**.
4. Si aparece **Google Play Protect** ("Se bloqueó la app no segura" / "se diseñó para una
   versión anterior de Android"): tocar **Más detalles → Instalar de todas formas**. El
   aviso se debe a que la app aún apunta a Android 13; no es un problema de seguridad del
   APK, que va firmado por NeoDesk.

Las actualizaciones se instalan igual, encima de la versión anterior, sin perder la
configuración.

## Para que el teléfono pueda ser controlado

En la pestaña **Compartir pantalla**, la tarjeta *Permitir el control de este teléfono*
guía los tres pasos y desaparece cuando están hechos:

1. **Fijar una contraseña permanente.** Es la que se escribe desde la PC para entrar.
2. **Iniciar el servicio** y aceptar el aviso de grabación de pantalla de Android.
3. **Activar "NeoDesk Input"** en *Ajustes → Accesibilidad*. Si el interruptor aparece
   en gris (Android 13 o superior): *Ajustes → Aplicaciones → NeoDesk → menú ⋮ →
   Permitir ajustes restringidos*, y volver a intentarlo.

Recomendado: desactivar el ahorro de batería para NeoDesk
(*Ajustes → Aplicaciones → NeoDesk → Batería → Sin restricciones*), para que Android no
cierre el servicio.

### Límites que pone Android (no se pueden saltar)

- El aviso de grabación de pantalla aparece cada vez que se inicia el servicio.
- Tras reiniciar el teléfono hay que desbloquearlo en persona y volver a iniciar el
  servicio.
- No se puede escribir en la pantalla de bloqueo del teléfono a distancia.
- Algunas marcas (Xiaomi, Huawei, Oppo, etc.) cierran apps en segundo plano de forma
  agresiva; el ajuste de batería de arriba lo reduce.

Por esto, el control de un teléfono está pensado para **soporte con alguien delante**,
no para acceso desatendido como en una PC.
