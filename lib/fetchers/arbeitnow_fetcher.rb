# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  class ArbeitnowFetcher < BaseFetcher
    URL = "https://www.arbeitnow.com/api/job-board-api"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      jobs = data["data"] || []

      jobs
        .select { |j| matches_keywords?(j["title"]) || matches_keywords?(j["description"]) }
        .map do |j|
          job_row(
            id:        j["slug"],
            title:     j["title"],
            company:   j["company_name"],
            location:  j["location"] || "Remote",
            url:       j["url"],
            salary:    "Not specified",
            posted_at: Time.at(j["created_at"]).utc.iso8601
          )
        end
    rescue StandardError => e
      warn "Arbeitnow error: #{e.message}"
      []
    end
  end
end
