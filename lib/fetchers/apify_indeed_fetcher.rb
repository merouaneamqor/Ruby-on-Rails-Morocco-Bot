# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require_relative "base_fetcher"

module Fetchers
  # Fetches Ruby on Rails jobs from Indeed via the Apify Indeed Scraper actor.
  #
  # Actor: https://apify.com/hMvNSpz3JnHgl5jkh (Indeed Jobs Scraper)
  # Uses the synchronous run-and-get-dataset endpoint so no polling is needed.
  #
  # Prerequisites:
  #   APIFY_API_TOKEN — from https://console.apify.com/account/integrations
  #
  # If the token is missing the fetcher skips silently.
  class ApifyIndeedFetcher < BaseFetcher
    ACTOR_ID = "hMvNSpz3JnHgl5jkh"
    # run-sync-get-dataset-items: runs the actor and returns results in one call
    BASE_URL = "https://api.apify.com/v2/acts/#{ACTOR_ID}/run-sync-get-dataset-items"

    # Apify actors can take a while; use a generous read timeout
    READ_TIMEOUT_APIFY = 270

    def fetch
      token = ENV["APIFY_API_TOKEN"]
      unless token
        warn "Apify: skipped (set APIFY_API_TOKEN in .env)"
        return []
      end

      # Run one search per keyword and collect unique jobs
      keywords.flat_map { |kw| fetch_for_keyword(kw, token) }.uniq { |j| j[:url] }
    rescue StandardError => e
      warn "Apify error: #{e.message}"
      []
    end

    private

    def fetch_for_keyword(keyword, token)
      url = "#{BASE_URL}?token=#{token}&format=json&limit=50"
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT_APIFY

      payload = JSON.generate(
        position:            keyword,
        maxItemsPerSearch:   50,
        country:             "US",
        saveOnlyUniqueItems: true,
        followApplyRedirects: false
      )

      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json"
      req["User-Agent"]   = USER_AGENT
      req.body = payload

      res = http.request(req)
      unless res.code.to_i == 200
        warn "Apify (#{keyword}) HTTP #{res.code}"
        return []
      end

      items = JSON.parse(res.body)
      return [] unless items.is_a?(Array)

      items
        .select { |j| matches_keywords?(j["positionName"] || j["title"]) }
        .map do |j|
          salary = if j["salary"]
                     j["salary"]
                   elsif j["salaryMin"]
                     "$#{j["salaryMin"]}–$#{j["salaryMax"]}"
                   else
                     "Not specified"
                   end

          apply_url = j["externalApplyLink"] || j["url"] || j["jobUrl"] ||
                      "https://www.indeed.com/viewjob?jk=#{j["id"]}"

          job_row(
            id:        j["id"].to_s,
            title:     j["positionName"] || j["title"],
            company:   j["company"],
            location:  j["location"] || "Remote",
            url:       apply_url,
            salary:    salary,
            posted_at: j["postedAt"] || j["datePosted"]
          )
        end
    rescue StandardError => e
      warn "Apify keyword '#{keyword}' error: #{e.message}"
      []
    end
  end
end
