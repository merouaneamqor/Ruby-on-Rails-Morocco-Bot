# frozen_string_literal: true

module Notifiers
  # Placeholder for future Slack webhook notifications.
  # Configure with SLACK_WEBHOOK_URL.
  class SlackNotifier
    def initialize(_webhook_url: nil)
      # TODO: implement when needed
    end

    def notify(jobs)
      return if jobs.empty?
      # TODO: post to Slack incoming webhook
    end
  end
end
