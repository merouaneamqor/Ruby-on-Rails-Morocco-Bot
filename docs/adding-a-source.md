# Adding a new job board source

This guide explains how to add a new fetcher so the bot can pull Rails jobs from another job board.

## 1. Create a new fetcher class

Add a file under `lib/fetchers/` named `your_source_fetcher.rb` (e.g. `we_work_remotely_fetcher.rb`).

Your class must:

- Inherit from `Fetchers::BaseFetcher`.
- Implement `#fetch`, which returns an array of job hashes with **symbol keys**.

### Required job hash keys

| Key         | Description                    |
|------------|--------------------------------|
| `:id`      | Unique id (e.g. `"sourcename-123"`) |
| `:source`  | Display name of the board      |
| `:title`   | Job title                      |
| `:company` | Company name                   |
| `:location`| e.g. "Remote", "Worldwide"     |
| `:url`     | Link to the job posting        |
| `:salary`  | "Not specified" or value      |
| `:posted_at`| Publication date (string)     |
| `:fetched_at`| ISO8601 time (use `Time.now.utc.iso8601`) |

### Example skeleton

```ruby
# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  class WeWorkRemotelyFetcher < BaseFetcher
    URL = "https://api.example.com/jobs"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      jobs = data["jobs"] || []

      jobs
        .select { |j| matches_keywords?(j["title"]) }
        .map do |j|
          job_row(
            id:        j["id"],
            title:     j["title"],
            company:   j["company_name"],
            location:  j["location"] || "Remote",
            url:       j["url"],
            salary:    j["salary"] || "Not specified",
            posted_at: j["published_at"]
          )
        end
    rescue StandardError => e
      warn "WeWorkRemotely error: #{e.message}"
      []
    end

    # Optional: override if your source id prefix should differ (e.g. "wwr")
    # def source_id
    #   "wwr"
    # end
  end
end
```

Helper methods from `BaseFetcher`:

- `get(url)` – HTTP GET; returns response body or `nil`.
- `keywords` – list of search keywords from config.
- `matches_keywords?(text)` – true if `text` contains any keyword.
- `job_row(id:, title:, company:, location:, url:, salary:, posted_at:)` – builds the standard hash and sets `:source`, `:fetched_at`, and `:id` prefix.

## 2. Register the fetcher in the runner

In `lib/rails_jobs/runner.rb`, add your fetcher to the `fetchers` array:

```ruby
def fetchers
  [
    Fetchers::RemotiveFetcher.new(config: @config),
    Fetchers::TheMuseFetcher.new(config: @config),
    Fetchers::ArbeitnowFetcher.new(config: @config),
    Fetchers::HimalayasFetcher.new(config: @config),
    Fetchers::WeWorkRemotelyFetcher.new(config: @config)  # new
  ]
end
```

Require the new file at the top of `runner.rb`:

```ruby
require_relative "../fetchers/we_work_remotely_fetcher"
```

## 3. Add specs

Create `spec/fetchers/we_work_remotely_fetcher_spec.rb` (or your source name). See existing fetcher specs for the pattern: call `#fetch` and assert the result is an array and each job has the required keys and the correct `:source`.

## 4. Optional: config/settings.yml

If your source needs API keys or config, add them to `config/settings.yml` and read them in `RailsJobs::Config` (and/or via ENV). Prefer ENV for secrets.

## 5. Documentation

Update `README.md` to list the new source, and if useful add a short note in `docs/adding-a-source.md` or in a new doc.

---

After that, run `bundle exec rspec` and `bundle exec rubocop`, then open a PR.
