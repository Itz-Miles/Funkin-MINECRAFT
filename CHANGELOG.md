# Changelog for Funkin-MINECRAFT
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.1.0] - August 19 2025

### Added
* Added push-button support to blockUI.
* Added bindable onPush function for buttons.
* Added support for creating arrays of layers after panel creation.
* Added a super early chart editor UI layout. Press 8 in the Freeplay Menu.

### Changed
* Implemented mouse and gamepad support for the settings submenus.
* Reorganized the codebase structure into states and objects.
* Moved some utillity functions CoolUtil to more fitting classes.

### Removed
* Removed some unused imports.


## [0.0.3] - August 13 2025

### Added
* Added layer-based button support to blockUI.
* Added bindable onClick, onHover, onRelease functions for buttons.
* Added support for procedurally creating layers after panel creation.
* Added support for indexing through sprites and buttons.
* Added a clickable back button to the dynamic header.

### Changed
* Overhauled the Main Menu buttons to be translucent.
* Implemented mouse and gamepad support for the buttons.
* Made music fade out when pressing the Story Mode button.
* Adjusted the strum note size and positions to have a 50 pixel margin.
* Adjusted the freeplay description box to have a 50 pixel margin.
* Adjusted the settings description boxes to have a 50 pixel margin.
* Adjusted the Haxe formatter to handle object literals Allman-style.

### Fixed
* Fixed unimplemented mouse support for Pause and Settings buttons.
* Fixed Control Keybinds' offsets and hitboxes to align with backings.

### Removed
* Removed the old Main Menu's sidebar assets. Images not needed!
* Removed some placeholder credits for now.
* Removed some unused imports.


## [0.0.2] - August 5 2025

### Added
* Created blockUI system for procedurally creating and caling UI elements. Soon to ba a haxelib!
* Created blockUI Panel, Layer, LayerData for object/deferred code layers.
* Added a dynamic header with fluid animations.

### Changed
* Upgraded to flixel 5.9.0.
* Improved the transition betwwen the Main Menu and Title Menu
* Changed the keyboard/controller assets to be "more retro".

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
