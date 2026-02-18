# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Notifiers
  class DiscordNotifier
    def initialize(webhook_url:, footer: nil, limit: 5, sleep_seconds: 1, role_id: nil)
      @webhook_url   = webhook_url
      @footer        = footer || "Rails Jobs Morocco 🇲🇦 • rails-jobs-morocco"
      @limit         = limit
      @sleep_seconds = sleep_seconds
      @role_id       = role_id.to_s.strip.empty? ? nil : role_id.to_s.strip
    end

    def notify(jobs)
      return 0 if jobs.empty?
      return 0 if @webhook_url.to_s.strip.empty?

      count = 0
      jobs.first(@limit).each_with_index do |job, index|
        mention_first = (index == 0)
        count += 1 if post_one(job, mention_first: mention_first)
        sleep @sleep_seconds
      end
      count
    end

    private

    def post_one(job, mention_first: false)
      payload = {
        embeds: [
          {
            title:     "💎 #{job[:title]}",
            url:       job[:url],
            color:     0xCC0000,
            fields:    [
              { name: "🏢 Company",   value: job[:company].to_s,   inline: true },
              { name: "📍 Location",  value: job[:location].to_s, inline: true },
              { name: "💰 Salary",    value: job[:salary].to_s,    inline: true },
              { name: "🔗 Source",    value: job[:source].to_s,     inline: true },
              { name: "📅 Posted",    value: job[:posted_at].to_s, inline: true }
            ],
            footer:    { text: @footer },
            timestamp: Time.now.utc.iso8601
          }
        ]
      }
      if mention_first
        payload["content"] = @role_id ? "<@&#{@role_id}> New Rails job(s) 🚀" : "@everyone New Rails job(s) 🚀"
      end

      uri = URI.parse(@webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 15
      req = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
      req.body = payload.to_json
      response = http.request(req)

      if response.code.to_i >= 400
        warn "Discord webhook error: #{response.code} #{response.body}"
        return false
      end
      true
    rescue StandardError => e
      warn "Discord webhook failed: #{e.message}"
      false
    end
  end
end
