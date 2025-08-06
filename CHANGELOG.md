# Changelog for Funkin-MINECRAFT
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [0.0.2] - August 5 2025

### Added
* Created blockUI system for procedurally creating and caling UI elements. Soon to ba a haxelib!
* Created blockUI Panel, Layer, LayerData for object/deferred code layers.
* Added a dynamic header with fluid animations.

### Changed
* Upgraded to flixel 5.9.0.
* Improved the transition betwwen the Main Menu and Title Menu
* Changed the keyboard/controller assets to be "more retro".

<img src="https://github.com/Itz-Miles/Funkin-MINECRAFT/blob/ebd7f7bfa8c1be2106173217c4bb55293628dfa9/assets/shared/images/controllertype.png?raw=true" width="128">
<img src="https://github.com/Itz-Miles/Funkin-MINECRAFT/blob/53c11d61782bffc18ea98c61cf4db4e1d06c6594/assets/shared/images/settings/controller_type.png?raw=true" width="128">

### Fixed
* Upgraded to flixel 5.9.0 to fix camera blendmode issues.
* Fixed Main Menu message with cliprect.

### Removed
* Removed some unused classes.
* Removed unused imports.

## [0.0.1] - July 25 2025

### Added
* Added a build date Haxe define in project.xml

### Changed
* Migrated to Haxe 4.3.7.
* Temporarily downgrade flixel to 5.8.0.
* FPS text updates periodically rather than every frame.
* FPS text deactivates/activates on window unfocus/focus.

### Fixed
* Mitigated FPSCounter TextField memory leak.
* Downgraded flixel to fix bgColor bug between state switches.


## [0.0.0] - August 4 2024

### Added
* Added an early build of Funkin' MINECRAFT dating August 4 2024

### Changed
* Migrated flixel, lime, and openfl libraries to version, version, version. (more info needed)
