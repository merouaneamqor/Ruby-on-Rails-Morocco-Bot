# Ruby on Rails Morocco Bot

**Repo:** [github.com/merouaneamqor/Ruby-on-Rails-Morocco-Bot](https://github.com/merouaneamqor/Ruby-on-Rails-Morocco-Bot)

A small Ruby bot that fetches **Ruby on Rails** (and related) remote job listings from several job boards, stores them in JSON, and optionally notifies a Discord channel when new jobs appear (pings **@everyone** or a role by default).

## Features

- **Multiple sources**: Remotive, The Muse, Arbeitnow, Himalayas
- **Configurable**: YAML config + environment variables; no code changes needed for keywords or paths
- **Discord notifications**: Optional webhook for new jobs (embeds with company, location, salary, etc.)
- **GitHub Actions**: Hourly cron (and manual run) to keep `data/jobs.json` updated
- **Extensible**: Add new fetchers and notifiers (Telegram/Slack placeholders included)

## Requirements

- Ruby >= 3.1
- No external APIs keys required for the default job boards

## Quick start

```bash
git clone https://github.com/merouaneamqor/Ruby-on-Rails-Morocco-Bot.git
cd Ruby-on-Rails-Morocco-Bot
bundle install
```

Run the fetcher:

```bash
bundle exec ruby bin/fetch
```

Jobs are written to `data/jobs.json` by default. For Discord notifications, copy `.env.example` to `.env` and set `DISCORD_WEBHOOK_URL`; the first new-job message will ping **@everyone** unless you set `DISCORD_ROLE_ID`.

## Configuration

| Env var | Description | Default |
|--------|-------------|--------|
| `RAILS_JOBS_OUTPUT_FILE` | Path to JSON output | `data/jobs.json` |
| `RAILS_JOBS_LOG_FILE` | Log file path | `rails_jobs.log` |
| `RAILS_JOBS_KEYWORDS` | Comma-separated keywords | ruby on rails, rails developer, ruby developer, ror developer |
| `DISCORD_WEBHOOK_URL` | Discord webhook for new jobs | (none) |
| `DISCORD_ROLE_ID` | Optional role to mention (default: @everyone) | (none) |
| `DISCORD_FOOTER` | Footer text on Discord embeds | RoR Morocco Job Bot 🇲🇦 • rails-jobs-morocco |
| `DISCORD_LIMIT` | Max new jobs to send per run | 5 |
| `DISCORD_SLEEP` | Seconds between Discord posts | 1 |

You can also edit `config/settings.yml` for defaults; env vars override YAML.

## Project layout

```
Ruby-on-Rails-Morocco-Bot/
├── .github/workflows/fetch_jobs.yml   # Hourly cron + manual run
├── bin/fetch                          # Entry point
├── config/settings.yml                # Config (keywords, paths, etc.)
├── data/jobs.json                     # Fetched jobs (created on first run)
├── lib/
│   ├── fetchers/                      # Job board adapters
│   ├── notifiers/                     # Discord (Telegram/Slack placeholders)
│   ├── storage/json_store.rb          # Read/write jobs.json
│   └── rails_jobs/                    # Config, runner
├── spec/                              # RSpec tests
├── docs/                              # Contributing, adding sources
├── .env.example
├── Gemfile
├── LICENSE
└── README.md
```

## GitHub Actions

1. In your fork or repo, add a secret: **Settings → Secrets and variables → Actions → New repository secret**  
   - Name: `DISCORD_WEBHOOK_URL`  
   - Value: your Discord webhook URL  

2. The workflow runs every hour and on **Actions → Fetch Rails Jobs → Run workflow**.

3. Optionally, the workflow can commit updated `data/jobs.json` (step is included; adjust if you don’t want commits).

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

See [docs/contributing.md](docs/contributing.md) and [docs/adding-a-source.md](docs/adding-a-source.md) for contributing and adding new job sources.

## License

MIT. See [LICENSE](LICENSE).
