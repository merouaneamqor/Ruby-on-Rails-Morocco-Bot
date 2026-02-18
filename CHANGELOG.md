# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-18

### Added

- Fetchers: Remotive, The Muse, Arbeitnow, Himalayas
- Discord notifier for new jobs (optional, via `DISCORD_WEBHOOK_URL`)
- JSON storage for jobs (`data/jobs.json` by default)
- Config via `config/settings.yml` and environment variables
- GitHub Action workflow for hourly fetch (`workflow_dispatch` for manual run)
- Issue and PR templates
- Docs: contributing, adding a new source
- RSpec tests for fetchers, Discord notifier, JSON store
- RuboCop configuration

[1.0.0]: https://github.com/merouaneamqor/Ruby-on-Rails-Morocco-Bot/releases/tag/v1.0.0
