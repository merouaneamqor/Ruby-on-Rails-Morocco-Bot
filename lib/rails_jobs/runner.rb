# frozen_string_literal: true

require "logger"
require "time"

require_relative "config"
require_relative "../fetchers/base_fetcher"
require_relative "../fetchers/remotive_fetcher"
require_relative "../fetchers/arbeitnow_fetcher"
require_relative "../fetchers/himalayas_fetcher"
require_relative "../fetchers/the_muse_fetcher"
require_relative "../notifiers/discord_notifier"
require_relative "../storage/json_store"

module RailsJobs
  class Runner
    def initialize(config: RailsJobs::Config)
      @config = config
      @store  = Storage::JsonStore.new(path: @config.output_file)
      @logger = Logger.new(@config.log_file)
      @logger.level = Logger::INFO
    end

    def run
      puts "🔍 [#{Time.now}] Fetching Ruby on Rails jobs..."

      existing = @store.load
      all_fetched = fetchers.flat_map { |f| f.fetch }
      new_jobs = all_fetched.reject { |job| existing.any? { |j| j["id"] == job[:id] } }

      if new_jobs.empty?
        puts "✅ No new jobs found."
        @logger.info("No new jobs found.")
      else
        puts "🚀 #{new_jobs.count} new job(s) found!"
        @logger.info("#{new_jobs.count} new jobs fetched.")

        all_jobs = existing + new_jobs.map { |j| j.transform_keys(&:to_s) }
        @store.save(all_jobs)

        notify_discord(new_jobs)
      end

      puts "📁 Total jobs stored: #{@store.load.count}"
    end

    private

    def fetchers
      [
        Fetchers::RemotiveFetcher.new(config: @config),
        Fetchers::TheMuseFetcher.new(config: @config),
        Fetchers::ArbeitnowFetcher.new(config: @config),
        Fetchers::HimalayasFetcher.new(config: @config)
      ]
    end

    def notify_discord(jobs)
      url = @config.discord_webhook_url
      if url.to_s.strip.empty?
        puts "⚠️  Discord: skipped (set DISCORD_WEBHOOK_URL in .env or export it)"
        return
      end

      notifier = Notifiers::DiscordNotifier.new(
        webhook_url:   url,
        footer:        @config.discord_footer,
        limit:         @config.discord_limit,
        sleep_seconds: @config.discord_sleep,
        role_id:       @config.discord_role_id
      )
      sent = notifier.notify(jobs)
      if sent && sent > 0
        puts "📤 Sent #{sent} job(s) to Discord."
      elsif sent == 0
        puts "⚠️  Discord: no messages sent (check webhook URL or see errors above)."
      end
    end
  end
end
