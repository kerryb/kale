# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Report tests as "features" when running `mix test`
- Allow keyword lists and `:ok` tuples for returning context (not just maps)
- Set minimum Elixir version to 1.3 (when `describe` was added to ExUnit)
- Link to source code from docs
- Add licence to docs
- Add this changelog

## [0.5.1] - 2019-06-07

### Added

- Improved documentation
- More checks, and a makefile

## [0.5.0] - 2019-06-06

### Changed

- Automatically make interpolated variables available in steps
- Make context argument optional

## [0.4.0] - 2019-06-05

### Changed

- Specify steps as multiline strings
- Pass context between steps

## [0.3.0] - 2019-06-04

### Changed

- Make `args` and `context` explicit arguments of `defwhen` etc

## [0.2.0] - 2019-05-27

### Changed

- Move `FeatureCase` into `Kale` namespace

## [0.1.1] - 2019-05-27

### Added

- Include README in generated docs

## [0.1.0] - 2019-05-27

### Added

- Initial release

[Unreleased]: https://github.com/kerryb/kale/compare/0.5.1...HEAD
[0.5.1]: https://github.com/kerryb/kale/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/kerryb/kale/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/kerryb/kale/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/kerryb/kale/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/kerryb/kale/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/kerryb/kale/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/kerryb/kale/releases/tag/0.1.0
