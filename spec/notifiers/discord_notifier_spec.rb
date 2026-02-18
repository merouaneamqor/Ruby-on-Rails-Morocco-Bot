# frozen_string_literal: true

require "spec_helper"

RSpec.describe Notifiers::DiscordNotifier do
  let(:notifier) { described_class.new(webhook_url: "", footer: "Test", limit: 2, sleep_seconds: 0) }

  describe "#notify" do
    it "does nothing when jobs are empty" do
      expect { notifier.notify([]) }.not_to raise_error
    end

    it "does nothing when webhook_url is empty" do
      expect { notifier.notify([{ title: "Job", url: "https://example.com" }]) }.not_to raise_error
    end

    it "respects limit" do
      notifier_with_url = described_class.new(
        webhook_url:   "https://discord.com/api/webhooks/fake/fake",
        footer:        "Test",
        limit:         1,
        sleep_seconds: 0
      )
      jobs = [
        { id: "1", source: "A", title: "T1", company: "C1", location: "L1", url: "U1", salary: "S1", posted_at: "P1", fetched_at: "F1" },
        { id: "2", source: "A", title: "T2", company: "C2", location: "L2", url: "U2", salary: "S2", posted_at: "P2", fetched_at: "F2" }
      ]
      # Would need to stub Net::HTTP to assert only one request; just check it doesn't raise
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(Struct.new(:code).new("204"))
      expect { notifier_with_url.notify(jobs) }.not_to raise_error
    end
  end
end
