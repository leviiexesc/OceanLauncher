# Ocean Launcher build guide

Ocean Launcher is a branded iOS build of the existing Zenith/Pojav-derived launcher. The Java launcher, JVM bridge, renderers, authentication flow, profiles, and download implementation remain in the native target. Ocean-specific UI lives in `Natives/OceanHomeViewController.*`.

## Requirements

Build on macOS. Xcode cannot compile iOS targets on Windows.

- macOS with Xcode and the matching iOS SDK
- Xcode command line tools
- GNU Make (`gmake` is used by the legacy Xcode target)
- CMake 3.6 or newer
- JDK 8 for the bootstrap compiler
- `wget`, `unzip`, `zip`, and `ldid`
- An Apple Developer team and a provisioning profile for `com.oceanlauncher.minecraft`
- The Java 8, 17, 21, and 25 runtime archives expected by the Makefile

The repository vendors AFNetworking, renderers, native bridges, and the Java-side launcher sources. Do not replace these with a new Minecraft launching engine.

## Configure signing

1. Open `ZenithLauncher.xcodeproj` in Xcode.
2. Select the `Ocean Launcher` legacy target and choose your Apple Developer team.
3. Create or select an App ID for `com.oceanlauncher.minecraft`.
4. Update `TEAMID`, `SIGNING_TEAMID`, and `PROVISIONING` in the Xcode target build settings or pass them to Make.
5. Keep the required JIT and sideload entitlements appropriate to the installation method. A normal App Store signing flow is not supported by this launcher architecture.

## Build an IPA

From the repository root on macOS:

```sh
make clean
make RELEASE=1 TEAMID=YOUR_TEAM_ID SIGNING_TEAMID=YOUR_TEAM_ID PROVISIONING=/path/to/profile.mobileprovision
```

The packaged artifact is written to `artifacts/com.oceanlauncher.minecraft-1.0-ios.ipa` (the exact suffix includes the platform and version). A slim package can be produced with `SLIMMED=1` when bundled runtimes are installed separately.

You can also select the `Ocean Launcher` scheme in Xcode and use Product > Build. The Xcode project delegates the actual build to Make; it is not a replacement build system.

## Install for personal testing

Use Xcode Devices and Simulators, Apple Configurator, or a compatible sideloading tool. On iOS versions that require JIT for usable Java performance, enable JIT using the supported AltServer/sideload workflow described by the upstream project. The device must have a compatible arm64 renderer and enough storage for Java runtimes, libraries, assets, and game instances.

## Architecture map

- `Natives/LauncherMenuViewController.m`: existing sidebar/navigation shell.
- `Natives/OceanHomeViewController.m`: Ocean dashboard UI and entry points.
- `Natives/LauncherProfilesViewController.m` and `LauncherProfileEditorViewController.m`: profiles, loaders, Java version, renderer, and deletion.
- `Natives/LauncherPreferencesViewController.m`: memory, runtime, renderer, resolution, FPS, controls, and theme preferences.
- `Natives/LauncherNavigationController.m`: Mojang version metadata, profile selection, installation/download progress, and play action.
- `Natives/AccountListViewController.m` plus `Natives/authenticator/`: Microsoft and local/offline account flows.
- `Natives/JavaLauncher.m`: JVM environment setup, runtime selection, renderer setup, and Minecraft process launch. This file is intentionally unchanged by the Ocean UI work.
- `JavaApp/`: Java-side launcher and LWJGL compatibility code.
- `Natives/external/` and `Natives/resources/Frameworks/`: third-party libraries and graphics/runtime support.

## License and attribution

The project remains GPL-3.0. Keep `LICENSE`, upstream notices, and third-party license information when distributing builds. Ocean Launcher branding and UI changes do not grant permission to redistribute Mojang assets or bypass Microsoft authentication. Use only accounts and game files you are legally entitled to use.
