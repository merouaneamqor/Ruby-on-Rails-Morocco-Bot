# Contributing to Ruby on Rails Morocco Bot

Thanks for your interest in contributing.

## Setup

```bash
git clone https://github.com/merouaneamqor/Ruby-on-Rails-Morocco-Bot.git
cd Ruby-on-Rails-Morocco-Bot
bundle install
cp .env.example .env   # optional: add your DISCORD_WEBHOOK_URL for testing
```

## Running the fetcher

```bash
bundle exec ruby bin/fetch
```

## Running tests

```bash
bundle exec rspec
```

## Code style

Run RuboCop before submitting:

```bash
bundle exec rubocop
```

## Adding a new job source

See [adding-a-source.md](adding-a-source.md).

## Pull requests

1. Open an issue or comment on an existing one so we can align.
2. Fork the repo, create a branch, make your changes.
3. Add or update tests as needed.
4. Run `bundle exec rspec` and `bundle exec rubocop`.
5. Open a PR using the pull request template.
6. Keep PRs focused; we may ask for changes or suggest splitting.

## Reporting bugs

Use the [bug report issue template](../.github/ISSUE_TEMPLATE/bug_report.md) and include Ruby version, OS, and steps to reproduce.

## Feature ideas

Use the [feature request template](../.github/ISSUE_TEMPLATE/feature_request.md). Discussion in an issue before a big PR is welcome.
