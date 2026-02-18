# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  class RemotiveFetcher < BaseFetcher
    URL = "https://remotive.com/api/remote-jobs?category=software-dev&limit=100"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      jobs = data["jobs"] || []

      jobs
        .select { |j| matches_keywords?(j["title"]) || matches_keywords?(j["tags"]) }
        .map do |j|
          job_row(
            id:         j["id"],
            title:      j["title"],
            company:    j["company_name"],
            location:   j["candidate_required_location"] || "Worldwide",
            url:        j["url"],
            salary:     j["salary"] || "Not specified",
            posted_at:  j["publication_date"]
          )
        end
    rescue StandardError => e
      warn "Remotive error: #{e.message}"
      []
    end
  end
end
