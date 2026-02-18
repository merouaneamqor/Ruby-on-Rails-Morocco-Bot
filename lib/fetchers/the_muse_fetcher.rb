# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  class TheMuseFetcher < BaseFetcher
    URL = "https://www.themuse.com/api/public/jobs?category=Software%20Engineer&level=Senior%20Level&level=Mid%20Level&page=1"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      results = data["results"] || []

      results
        .select { |j| matches_keywords?(j["name"]) }
        .map do |j|
          location = j["locations"]&.map { |l| l["name"] }&.join(", ") || "Remote"
          job_row(
            id:        j["id"],
            title:     j["name"],
            company:   j.dig("company", "name"),
            location:  location,
            url:       j["refs"]["landing_page"],
            salary:    "Not specified",
            posted_at: j["publication_date"]
          )
        end
    rescue StandardError => e
      warn "The Muse error: #{e.message}"
      []
    end

    private

    def source_id
      "muse"
    end
  end
end
