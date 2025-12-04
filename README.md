# Squabble

## Naming Conventions
 
 Please ensure files and directories are named consistently, preferably following the naming conventions as detailed in the [GDScript style guide](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html#naming-conventions).


 ---

 ## Letter Cases

To ensure the project is always consistently maintainable across all platforms supported by the Godot editor, please also mind the letter cases when naming files and directories. While they are generally case-insensitive on Windows and Mac, they are **case-sensitive** on Linux. 

For example, on Windows and Mac, `res://shop/shop.gd`, `res://shop/Shop.gd`, and `res://Shop/shop.gd` are the same and they always refer to the same file regardless of the letter cases. However, on Linux, they are three **DIFFERENT** files.

Hence, we should always **assume file and directory names with same spellings but different letter cases to be entirely different from each other**. 

`Shop.gd`, `sHop.gd`, `shoP.gd`, `shop.GD`, and `shop.gd` are five entirely **DIFFERENT** files.

This is extremely important to avoid the project breaking on different systems, and also because:

1. It is a good practice to be consistent with file and directory names.
2. When we have multiplayer up and running, the server code will most likely be an extension of the current codebase and it will be deployed to Linux systems (**case-sensitive**) running in the cloud.
3. One of our programmers (Randy) uses Linux exclusively and has no access to Windows and Mac.


---

## CAUTION

Risk of getting banned from Google AdMob:

1. NEVER run the game with real ads if it was not downloaded from the Google Play Store.
2. Running an instance of the game with real ads not downloaded from the Google Play Store may get the game banned from Google AdMob.

---
## Plugins
Squabble uses these [Android plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/android/android_plugin.html):
* Google Play Games Services: https://github.com/oneseedfruit/PGSGP
* Google Play In-App Review: https://github.com/i-bardinov/Godot-GooglePlay-InApp-Review
* Godot AdMob Android: https://github.com/Poing-Studios/godot-admob-android 
* Firebase Analytics: https://github.com/DrMoriarty/godot-firebase-analytics
* Facebook: https://github.com/oneseedfruit/godot-facebook-android-sdk
* Appodeal: https://github.com/oneseedfruit/godot-appodeal-android-plugin
* Adjust: https://github.com/oneseedfruit/godot-android-adjust-plugin
* AppLovin: https://github.com/DrMoriarty/godot-applovin-max
* Tenjin: https://github.com/DrMoriarty/godot-tenjin

The following plugin is GDScript only:
* Firebase: https://github.com/GodotNuts/GodotFirebase

---

## Naming Exported Files in a Release

Ideally, please follow these conventions when naming exported builds:
1. Examples naming debug builds (for Gameka's internal use only):
   * `Squabble_0.7.2-alpha1_build_debug.apk`
   * `Squabble_0.7.4-alpha3_build_debug.apk`
   * `Squabble_0.7.4-alpha4_build_debug.apk`
   * `Squabble_0.7.3f1-alpha4_build_debug.apk`
   * `Squabble_0.7.3-fix5-alpha4_build_debug.apk`
2. Examples naming release builds (to be uploaded to the Google Play Store):   
   * `Squabble_0.7.2-build_release.apk`
   * `Squabble_0.7.4-build_release.apk`
   * `Squabble_0.7.2-fix5-alpha4_build_release.apk`
   
---

## Versioning
1. Squabble's Android version code should be incremented in a debug build to a value equals to the latest version code (of the biggest value) in the Google Play Store ("Open Testing" -> "Releases" -> "Show summary") + 1, but no more than that, until the next release builds are made and uploaded to the Google Play Store. Then, increment the version code in the next debug build.
2. Release builds (Android exports signed with the release keystore meant to be uploaded to the Google Play Store) are not uploaded to this repository. They should be done outside this repository.
3. Squabble's Android version name <em>loosely</em> follows [semantic versioning](https://semver.org).
   1. > Given a version number MAJOR.MINOR.PATCH, increment the:
        * >MAJOR version when you make incompatible API changes,
        * > MINOR version when you add functionality in a backwards compatible manner, and
        * >PATCH version when you make backwards compatible bug fixes.

        * >Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.
   2. `MAJOR.MINOR.PATCH-suffix#`
   3. <strong>DO NOT</strong> increment MAJOR number to be greater than 0 while Squabble is still in development ("Open Testing" a. k. a. "Early Access").
   4. All builds released in this repository should be debug exports only and are signed with the debug keystore. They are only meant for Gameka's internal use.
   5. Every <em>incremental</em> debug build (Android export signed with debug keystore) released internally here in this repository should be suffixed with `-alpha#` where `#` is an incrementing integer. For example,
      * `0.7.4-alpha1`
      * `0.7.4-alpha2`
      * `0.7.4-alpha3`
      * `0.7.4-alpha4`
   
      Incremental debug releases are meant for immediately testing recently pushed commits (when required). In the example above, they are all part of version `0.7.4`, but released as incremental builds multiple times.
   6. An incremental debug build may have the `-alpha#` suffix removed if there has been a significant number of changes since the last non-incremental debug build (debug build without `-alpha#`), either as a result of accumulating all the changes from prior incremental debug builds, or as a result of the current incremental debug build having too many changes. 
      * This is also the same build that is re-exported as a release build to be uploaded to the Google Play Store with real ads enabled in AdMob.
  
   
4. In the event that bugfixes are done after a release, and an immediate follow-up release is required to test or roll out the fixes, please suffix `-fix#` or `f#` after the patch number where `#` is an incrementing integer. For example, in debug builds:
    * `0.7.1f1-alpha1`
    * `0.7.2-fix3-alpha2`
    
    and in release builds (Android export signed with release keystore):
    * `0.7.2-fix2`
    * `0.7.3-fix1`

    However, it is preferable to use `-fix#` to be closer to semantic versioning. 
