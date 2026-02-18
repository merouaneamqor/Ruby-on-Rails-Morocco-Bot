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
        env_or_default("RAILS_JOBS_LOG_FILE", settings["log_file"] || DEFAULTS[:log_file])
      end

      def output_file
        env_or_default("RAILS_JOBS_OUTPUT_FILE", settings["output_file"] || DEFAULTS[:output_file])
      end

      def keywords
        kw = ENV["RAILS_JOBS_KEYWORDS"].to_s.strip
        if !kw.empty?
          kw.split(",").map(&:strip).map(&:downcase)
        elsif settings["keywords"].is_a?(Array) && settings["keywords"].any?
          settings["keywords"].map(&:to_s).map(&:downcase)
        else
          DEFAULTS[:keywords]
        end
      end

      def discord_webhook_url
        v = ENV["DISCORD_WEBHOOK_URL"].to_s.strip
        v.empty? ? nil : v
      end

      # Role ID to mention (e.g. "Job Seekers"). Format in Discord: <@&ROLE_ID>
      def discord_role_id
        id = env_or_default("DISCORD_ROLE_ID", nil) || settings.dig("discord", "role_id")
        id.to_s.strip.empty? ? nil : id.to_s.strip
      end

      def discord_footer
        env_or_default("DISCORD_FOOTER", "RoR Morocco Job Bot 🇲🇦 • rails-jobs-morocco")
      end

      def discord_limit
        (env_or_default("DISCORD_LIMIT", nil) || settings.dig("discord", "limit") || DEFAULTS[:discord_limit]).to_i
      end

      def discord_sleep
        (env_or_default("DISCORD_SLEEP", nil) || settings.dig("discord", "sleep") || DEFAULTS[:discord_sleep]).to_f
      end

      # Empty or missing ENV => use default (so GitHub Variables can be left unset)
      def env_or_default(key, default)
        v = ENV[key].to_s.strip
        v.empty? ? default : v
      end
    end
  end
end
