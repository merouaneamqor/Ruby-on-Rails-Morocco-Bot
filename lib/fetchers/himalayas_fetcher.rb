# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  class HimalayasFetcher < BaseFetcher
    URL = "https://himalayas.app/jobs/api?q=ruby+on+rails&limit=50"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      jobs = data["jobs"] || []

      jobs.map do |j|
        job_row(
          id:        (j["id"].to_s.strip.empty? ? j["url"].to_s.hash.abs : j["id"]).to_s,
          title:     j["title"],
          company:   j.dig("company", "name"),
          location:  j["locationRestrictions"]&.join(", ") || "Worldwide",
          url:       j["applicationLink"] || j["url"],
          salary:    j["salary"] || "Not specified",
          posted_at: j["publishedAt"]
        )
      end
    rescue StandardError => e
      warn "Himalayas error: #{e.message}"
      []
    end
  end
end
