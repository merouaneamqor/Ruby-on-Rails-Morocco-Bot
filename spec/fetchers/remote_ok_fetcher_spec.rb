# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fetchers::RemoteOkFetcher do
  let(:config) { RailsJobs::Config }
  let(:fetcher) { described_class.new(config: config) }

  describe "#fetch" do
    it "returns an array" do
      result = fetcher.fetch
      expect(result).to be_an(Array)
    end

    it "returns jobs with required keys" do
      result = fetcher.fetch
      result.each do |job|
        expect(job).to include(:id, :source, :title, :company, :location, :url, :salary, :posted_at, :fetched_at)
        expect(job[:source]).to eq("RemoteOk")
      end
    end
  end
end
