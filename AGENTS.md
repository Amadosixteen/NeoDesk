# NeoDesk Guide

NeoDesk es un cliente de escritorio remoto derivado de RustDesk (AGPL-3.0), con marca
propia de Geatel. Solo se construyen **Linux x86_64 (`.deb`)** y **Windows x86_64
(`.exe` + `.msi`)**; macOS, Android, iOS, web y Sciter siguen en el árbol pero no se
compilan ni se mantienen.

## Project Layout

### Directory Structure
* `src/` Rust app
* `src/server/` audio / clipboard / input / video / network
* `src/platform/` platform-specific code
* `src/ui/` legacy Sciter UI (deprecated)
* `flutter/` current UI
* `libs/hbb_common/` config / proto / shared utils
* `libs/scrap/` screen capture
* `libs/enigo/` input control
* `libs/clipboard/` clipboard
* `libs/hbb_common/src/config.rs` all options

### Key Components
- **Remote Desktop Protocol**: Custom protocol implemented in `src/rendezvous_mediator.rs` for communicating with the rendezvous server
- **Screen Capture**: Platform-specific screen capture in `libs/scrap/`
- **Input Handling**: Cross-platform input simulation in `libs/enigo/`
- **Audio/Video Services**: Real-time audio/video streaming in `src/server/`
- **File Transfer**: Secure file transfer implementation in `libs/hbb_common/`

### UI Architecture
- **Legacy UI**: Sciter-based (deprecated) - files in `src/ui/`
- **Modern UI**: Flutter-based - files in `flutter/`
  - Desktop: `flutter/lib/desktop/`
  - Mobile: `flutter/lib/mobile/`
  - Shared: `flutter/lib/common/` and `flutter/lib/models/`

## Marca NeoDesk — no revertir

Estos valores son la identidad del producto. Un merge desde upstream los pisa sin avisar;
revisarlos antes de dar por bueno cualquier rebase.

| Qué | Dónde | Valor |
|---|---|---|
| Nombre visible | `libs/hbb_common/src/config.rs` | `APP_NAME = "NeoDesk"` |
| Organización | `libs/hbb_common/src/config.rs` | `ORG = "com.geatel"` |
| Paquete Cargo | `Cargo.toml` | `name = "neodesk"`, `version = "1.0.0"` |
| Librería FFI | `Cargo.toml` `[lib]` | `libneodesk` |
| Binario Linux | `flutter/linux/CMakeLists.txt` | `BINARY_NAME "neodesk"` |
| Binario Windows | `flutter/windows/CMakeLists.txt` | `BINARY_NAME "neodesk"` |
| Metadatos del `.exe` | `Cargo.toml` `[package.metadata.winres]`, `flutter/windows/runner/Runner.rc` | `NeoDesk` / `neodesk.exe` |
| Empaquetador portable | `libs/portable/Cargo.toml` | `neodesk-portable-packer` |
| Instalador MSI | `.github/workflows/neodesk-build.yml` | `preprocess.py --app-name NeoDesk` |
| Colores | `flutter/lib/common.dart` | `accent 0xFF4F46E5`, `idColor`/`button 0xFF6366F1` |
| Logos e iconos | `flutter/assets/`, `res/` | isotipo Geatel; `res/scalable.svg` es el que usa Cinnamon |

**El copyright de Purslane Tech Pte. Ltd. y la licencia AGPL-3.0 se conservan.** Es
obligación de la licencia, no un descuido.

### Trampas conocidas

**`libs/hbb_common` está vendorizado, no es un submódulo.** Se eliminó `.gitmodules` a
propósito: cuando era submódulo, CI lo traía de upstream en cada build y `APP_NAME`
volvía a ser `RustDesk` sin que nada fallara.

**Renombrar un productor obliga a seguir a sus consumidores.** La librería la cargan por
nombre `flutter/linux/main.cc` (`dlopen`) y `flutter/windows/runner/main.cpp`
(`LoadLibraryA`), y los símbolos de entrada (`neodesk_core_main`,
`neodesk_core_main_args`, `neodesk_is_disable_installation`, `get_neodesk_app_name`) se
resuelven por cadena. Un desajuste **compila sin errores y revienta al arrancar**.
Verificar siempre con `nm -D` y ejecutando el binario, no solo con que termine el build.

**Las cadenas de `src/lang/*.rs` no se traducen a mano.** `src/lang.rs` sustituye
`RustDesk` por `APP_NAME` en tiempo de ejecución para clientes personalizados. Las únicas
excepciones codificadas son `powered_by_me` y `upgrade_rustdesk_server_pro*`.

**Las URLs `github.com/rustdesk*` y `rustdesk-org/*` son repos reales de upstream.** No
renombrarlas: el engine de Flutter, el driver de impresora y 16 dependencias git salen de
ahí.

## Recortes de interfaz (MVP)

Se ocultaron opciones comentándolas, con su etiqueta original intacta para poder
revertirlas una a una:

* `flutter/lib/desktop/widgets/remote_toolbar.dart` — fuera teclado, chat y llamada de
  voz; el menú de acciones usa `assets/settings_gear.svg`.
* `flutter/lib/common/widgets/toolbar.dart` — `toolbarControls()` deja solo Transferir
  archivo, Reiniciar dispositivo y Tomar captura de pantalla.
* `flutter/lib/models/peer_tab_model.dart` — solo Recientes, Favoritos y Red local.
* `flutter/lib/desktop/pages/connection_page.dart` — Conectar y Transferir archivos como
  botones visibles, sin desplegable.

## Compilación local (Linux)

No se compila en el host: se usa la imagen `neodesk-build:latest` definida en
`~/neodesk-build/`, con Rust 1.75, Flutter 3.24.5 y vcpkg fijados.

```bash
docker run --rm \
  -v ~/rustdesk-src:/home/dev/src \
  -v ~/neodesk-build/rebuild.sh:/rebuild.sh:ro \
  -v ~/neodesk-build/vcpkg-installed:/home/dev/vcpkg/installed \
  -v ~/neodesk-build/cargo-registry:/home/dev/.cargo/registry \
  -v ~/neodesk-build/cargo-git:/home/dev/.cargo/git \
  -v ~/neodesk-build/pub-cache:/home/dev/.pub-cache \
  --name neodesk-recompile neodesk-build:latest bash /rebuild.sh
```

Los cinco montajes son caché y deben persistir entre builds. Dos fallos que ya costaron
tiempo:

* Sin montar `pub-cache`, `~/.pub-cache` es efímero dentro del contenedor mientras
  `.dart_tool/` persiste en el fuente montado, y `generated_bridge.dart` sale con errores
  de tipo. No es corrupción de `pubspec.lock`.
* `build.py` compila con `cargo build --locked`. Al cambiar nombre o versión del paquete
  hay que actualizar `Cargo.lock` a mano o el build muere antes de compilar nada.

Con caché caliente son unos 7 minutos. El resultado es `neodesk-<version>.deb` en la raíz.

## Rust Rules

* Avoid `unwrap()` / `expect()` in production code.
* Exceptions:

  * tests;
  * lock acquisition where failure means poisoning, not normal control flow.
* Otherwise prefer `Result` + `?` or explicit handling.
* Do not ignore errors silently.
* Avoid unnecessary `.clone()`.
* Prefer borrowing when practical.
* Do not add dependencies unless needed.
* Keep code simple and idiomatic.

## Tokio Rules

* Assume a Tokio runtime already exists.
* Never create nested runtimes.
* Never call `Runtime::block_on()` inside Tokio / async code.
* Do not hide runtime creation inside helpers or libraries.
* Do not hold locks across `.await`.
* Prefer `.await`, `tokio::spawn`, channels.
* Use `spawn_blocking` or dedicated threads for blocking work.
* Do not use `std::thread::sleep()` in async code.

## Editing Hygiene

* Change only what is required.
* Prefer the smallest valid diff.
* Do not refactor unrelated code.
* Do not make formatting-only changes.
* Keep naming/style consistent with nearby code.

### Comments

* Avoid comments unless they explain a non-obvious reason, constraint, or workaround.
* Never restate what the code does; prefer clearer code instead.
* If the code is self-explanatory, add no comment.

### Be minimally invasive

* Prefer purely additive changes: layer new (`#[cfg]`-gated) blocks or new functions around existing code instead of restructuring it. The ideal diff for a fix adds lines and modifies/deletes none.
* Do not extract or reshape existing code just to enable your new code; look for a mechanism that leaves existing lines untouched (e.g. hide/show an existing object instead of refactoring its construction into a helper for rebuilding).
* Accept a little duplication over a restructure. A new function that repeats a few lines of an existing one is a better diff than reshaping the original so both can share it.
* Put new logic in self-contained functions in the module it belongs to (platform-specific logic in `src/platform/`, with `use` inside the function body to avoid churning shared import blocks). Call sites in shared files (`src/tray.rs`, `src/core_main.rs`, `src/server/connection.rs`, …) should be thin one-line hooks.

## Reviewing a PR

* Review only what the diff introduces. Verify ownership with `gh pr diff` before reporting a finding — if the offending lines are untouched context, it is a pre-existing problem, not this PR's.
* List pre-existing problems in a separate section at the end, or leave out the ones that are not fatal. Never mix them into the findings the author has to fix.
* Before re-reviewing, read the author's reply comments. Do not re-raise items they declined on scope grounds.
* State a finding's consequence exactly: distinguish "the value is lost" from "the shortcut is inert but the value still saves".

## Localization (`src/lang/*.rs`)

Each file is a `HashMap<key, translation>`. Layout:

* `template.rs` is the master list of every key. **Never edit it** as part of translation work.
* `en.rs` holds only the keys whose English display text differs from the key itself.
* Every other file (`de.rs`, `fr.rs`, …) carries the full key set; an untranslated entry has an empty value: `("key", "")`.

### Finding the English source for a key

When filling an empty entry, determine the source English text with this rule:

* If `key` exists in `en.rs` **with a non-empty value**, that value is the source text (look it up in `en.rs`).
* Otherwise the **key string itself is the source text** (the key is already plain English).

Then translate that source into the file's target language (infer the language from the file's existing non-empty entries / filename).

### Translation hygiene

* Only fill empty values. Never change keys, and never touch existing non-empty translations.
* Preserve placeholders (`{}`) and escape sequences (`\n`, `\"`) exactly as in the source.
* Do not translate brand or technical tokens: `NeoDesk`, `Socks5`, `TLS`, `UAC`, `Wayland`, `X11`, `TCP`, `UDP`, `2FA`, `RDP`, `D3D`, etc.
* Copy URL values (e.g. `doc_*` keys) verbatim from `en.rs`.

### Adding new keys (feature work)

* New English-text keys use sentence case, not Title Case: `Use ID whitelisting`, **not** `Use ID Whitelisting`. Acronyms (ID, IP, 2FA…) stay uppercase. Legacy Title-Case keys (e.g. `Use IP Whitelisting`) stay as-is — do not rename them.
* Since the key itself is the English display text, a sentence-case key usually needs **no** `en.rs` entry; add one only when the display text must differ from the key (e.g. `*_tip` keys).
* Append each new key to `template.rs` (with `""`) and to every `src/lang/*.rs` file (translated, or `""` if unsure), at the end of the list.
