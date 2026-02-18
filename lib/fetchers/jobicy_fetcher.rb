# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  # Fetches Ruby on Rails jobs from Jobicy's free public JSON API.
  # Docs: https://jobicy.com/jobs-rss-feed
  class JobicyFetcher < BaseFetcher
    URL = "https://jobicy.com/api/v2/remote-jobs?tag=ruby&count=50"

    def fetch
      body = get(URL)
      return [] unless body

      data = JSON.parse(body)
      jobs = data["jobs"] || []

      jobs
        .select { |j| matches_keywords?(j["jobTitle"]) || matches_keywords?(j["jobExcerpt"]) }
        .map do |j|
          job_row(
            id:        j["id"],
            title:     j["jobTitle"],
            company:   j["companyName"],
            location:  j["jobGeo"] || "Remote",
            url:       j["url"],
            salary:    j["annualSalaryMin"] ? "$#{j["annualSalaryMin"]}–$#{j["annualSalaryMax"]}" : "Not specified",
            posted_at: j["pubDate"]
          )
        end
    rescue StandardError => e
      warn "Jobicy error: #{e.message}"
      []
    end
  end
end
