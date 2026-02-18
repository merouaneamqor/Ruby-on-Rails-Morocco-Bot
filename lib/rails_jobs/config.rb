# frozen_string_literal: true

require "yaml"

module RailsJobs
  class Config
    DEFAULTS = {
      log_file: "rails_jobs.log",
      output_file: "data/jobs.json",
      keywords: [
        "ruby on rails",
        "rails developer",
        "ruby developer",
        "ror developer"
      ].freeze,
      discord_limit: 5,
      discord_sleep: 1
    }.freeze

    class << self
      def settings
        @settings ||= begin
          path = File.expand_path("../../config/settings.yml", __dir__)
          File.exist?(path) ? (YAML.load_file(path) || {}) : {}
        end
      end

      def log_file
        ENV.fetch("RAILS_JOBS_LOG_FILE", settings["log_file"] || DEFAULTS[:log_file])
      end

      def output_file
        ENV.fetch("RAILS_JOBS_OUTPUT_FILE", settings["output_file"] || DEFAULTS[:output_file])
      end

      def keywords
        if ENV["RAILS_JOBS_KEYWORDS"]
          ENV["RAILS_JOBS_KEYWORDS"].split(",").map(&:strip).map(&:downcase)
        elsif settings["keywords"].is_a?(Array) && settings["keywords"].any?
          settings["keywords"].map(&:to_s).map(&:downcase)
        else
          DEFAULTS[:keywords]
        end
      end

      def discord_webhook_url
        ENV["DISCORD_WEBHOOK_URL"]
      end

      # Role ID to mention (e.g. "Job Seekers"). Format in Discord: <@&ROLE_ID>
      def discord_role_id
        id = ENV["DISCORD_ROLE_ID"] || settings.dig("discord", "role_id")
        id.to_s.strip.empty? ? nil : id.to_s.strip
      end

      def discord_footer
        ENV.fetch("DISCORD_FOOTER", "RoR Morocco Job Bot 🇲🇦 • rails-jobs-morocco")
      end

      def discord_limit
        (ENV["DISCORD_LIMIT"] || settings.dig("discord", "limit") || DEFAULTS[:discord_limit]).to_i
      end

      def discord_sleep
        (ENV["DISCORD_SLEEP"] || settings.dig("discord", "sleep") || DEFAULTS[:discord_sleep]).to_f
      end
    end
  end
end
