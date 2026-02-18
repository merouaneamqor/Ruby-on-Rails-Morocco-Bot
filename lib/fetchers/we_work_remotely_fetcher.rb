# frozen_string_literal: true

require "rexml/document"
require_relative "base_fetcher"

module Fetchers
  # Fetches Ruby on Rails jobs from WeWorkRemotely's public RSS feed.
  class WeWorkRemotelyFetcher < BaseFetcher
    URL = "https://weworkremotely.com/categories/remote-programming-jobs.rss"

    def fetch
      body = get(URL, { "Accept" => "application/rss+xml, application/xml, text/xml" })
      return [] unless body

      doc = REXML::Document.new(body)
      jobs = []

      doc.elements.each("rss/channel/item") do |item|
        title   = item.elements["title"]&.text.to_s.strip
        link    = item.elements["link"]&.text.to_s.strip
        company = item.elements["region"]&.text.to_s.strip
        pubdate = item.elements["pubDate"]&.text.to_s.strip

        # WWR encodes title as "Company: Job Title"
        parts   = title.split(":", 2)
        company = parts[0].strip if parts.size > 1
        title   = parts.last.strip

        next unless matches_keywords?(title)

        jobs << job_row(
          id:        Digest::MD5.hexdigest(link)[0, 16],
          title:     title,
          company:   company,
          location:  "Remote",
          url:       link,
          posted_at: pubdate
        )
      end

      jobs
    rescue StandardError => e
      warn "WeWorkRemotely error: #{e.message}"
      []
    end
  end
end
