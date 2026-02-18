# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Fetchers
  # Abstract base for job board fetchers. Subclass and implement #fetch.
  class BaseFetcher
    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 15
    USER_AGENT   = "RailsJobsMorocco/1.0 (https://github.com/rails-jobs-morocco/rails-jobs-morocco)"

    def initialize(config:)
      @config = config
    end

    # Override in subclasses. Return array of hashes with symbol keys:
    #   id, source, title, company, location, url, salary, posted_at, fetched_at
    def fetch
      raise NotImplementedError, "#{self.class}#fetch must be implemented"
    end

    protected

    def get(url, headers = {})
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = USER_AGENT
      request["Accept"] = "application/json"
      headers.each { |k, v| request[k] = v }

      response = http.request(request)
      return nil unless response.code.to_i == 200

      response.body
    rescue StandardError => e
      warn "#{source_name} fetch error: #{e.message}"
      nil
    end

    def keywords
      @config.keywords
    end

    def source_name
      self.class.name.split("::").last.sub("Fetcher", "")
    end

    def job_row(id:, title:, company:, location:, url:, salary: "Not specified", posted_at:)
      {
        id:         "#{source_id}-#{id}",
        source:     source_name,
        title:      title,
        company:    company,
        location:   location,
        url:        url,
        salary:     salary,
        posted_at:  posted_at,
        fetched_at: Time.now.utc.iso8601
      }
    end

    # Short prefix for job id (e.g. "remotive", "arbeitnow")
    def source_id
      source_name.downcase.gsub(/\s+/, "-")
    end

    def matches_keywords?(text)
      return false if text.to_s.empty?
      down = text.to_s.downcase
      keywords.any? { |kw| down.include?(kw) }
    end
  end
end
