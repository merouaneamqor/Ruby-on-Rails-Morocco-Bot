# frozen_string_literal: true

require "digest"
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
        url = (j["applicationLink"] || j["url"]).to_s.strip
        # Stable id from URL so the same job is never treated as new again
        id = url.empty? ? j["id"].to_s : Digest::MD5.hexdigest(url).to_s[0, 16]
        id = "h#{id.hash.abs}" if id.to_s.strip.empty?

        job_row(
          id:        id,
          title:     j["title"],
          company:   j.dig("company", "name"),
          location:  j["locationRestrictions"]&.join(", ") || "Worldwide",
          url:       url.empty? ? "https://himalayas.app/jobs" : url,
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
