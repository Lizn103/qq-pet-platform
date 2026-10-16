# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Restructured project layout with English-named directories
- Windows installer (deploy/) with NSSM service registration
- Comprehensive .gitignore excluding secrets and runtime data
- Updated README with full documentation
- Auto-restart tunnel keeper for cloudflared URLs

### Changed
- Organized frontend/src/api/* into modular request handlers
- Consolidated deployment artifacts under deploy/

### Security
- Added .gitignore rules for config.ini, tokens, DB files
