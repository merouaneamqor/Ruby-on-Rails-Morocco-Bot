# frozen_string_literal: true

module Notifiers
  # Placeholder for future Telegram bot notifications.
  # Configure with TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID.
  class TelegramNotifier
    def initialize(_bot_token: nil, _chat_id: nil)
      # TODO: implement when needed
    end

    def notify(jobs)
      return if jobs.empty?
      # TODO: send messages via Telegram Bot API
    end
  end
end
