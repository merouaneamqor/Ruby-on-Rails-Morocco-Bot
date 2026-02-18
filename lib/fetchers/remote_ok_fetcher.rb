# frozen_string_literal: true

require_relative "base_fetcher"

module Fetchers
  # Fetches Ruby on Rails jobs from RemoteOK's public JSON API.
  # Docs: https://remoteok.com/api
  # Note: The first element of the response array is a metadata object — skip it.
  class RemoteOkFetcher < BaseFetcher
    URL = "https://remoteok.com/api?tag=ruby"

    def fetch
      body = get(URL, { "Accept" => "application/json" })
      return [] unless body

      raw = JSON.parse(body)
      # First element is a legal/meta notice object, not a job
      jobs = raw.is_a?(Array) ? raw.drop(1) : []

      jobs
        .select do |j|
          tags_text = Array(j["tags"]).join(" ")
          matches_keywords?(j["position"]) || matches_keywords?(tags_text)
        end
        .map do |j|
          job_row(
            id:        j["id"].to_s,
            title:     j["position"],
            company:   j["company"],
            location:  j["location"].to_s.empty? ? "Remote" : j["location"],
            url:       j["url"] || "https://remoteok.com/remote-jobs/#{j["id"]}",
            salary:    j["salary_min"] ? "$#{j["salary_min"]}–$#{j["salary_max"]}" : "Not specified",
            posted_at: j["date"]
          )
        end
    rescue StandardError => e
      warn "RemoteOK error: #{e.message}"
      []
    end
  end
end
