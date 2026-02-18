# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  # Fetches Ruby on Rails jobs from WellFound (formerly AngelList Talent).
  # Uses the public unauthenticated job listing endpoint.
  class WellfoundFetcher < BaseFetcher
    URL = "https://wellfound.com/jobs.json?role=engineer&skills[]=ruby-on-rails&remote=true"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      # Response shape: { "jobs" => [...] } or top-level array
      jobs = data.is_a?(Array) ? data : (data["jobs"] || data["startup_roles"] || [])

      jobs
        .select { |j| matches_keywords?(j["title"] || j["job_type"]) }
        .map do |j|
          company = j.dig("startup", "name") || j["company_name"] || "Unknown"
          url     = j["url"] || j["apply_url"] || "https://wellfound.com/jobs"
          job_row(
            id:        j["id"].to_s,
            title:     j["title"] || j["job_type"],
            company:   company,
            location:  j["remote"] ? "Remote" : (j["location"] || "Remote"),
            url:       url,
            posted_at: j["created_at"] || j["updated_at"]
          )
        end
    rescue StandardError => e
      warn "WellFound error: #{e.message}"
      []
    end
  end
end
