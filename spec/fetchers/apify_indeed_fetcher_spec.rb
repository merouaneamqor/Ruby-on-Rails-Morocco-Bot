# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fetchers::ApifyIndeedFetcher do
  let(:config) { RailsJobs::Config }
  let(:fetcher) { described_class.new(config: config) }

  describe "#fetch" do
    context "when APIFY_API_TOKEN is not set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("APIFY_API_TOKEN").and_return(nil)
      end

      it "returns an empty array without raising" do
        expect { fetcher.fetch }.not_to raise_error
        expect(fetcher.fetch).to eq([])
      end
    end

    context "when APIFY_API_TOKEN is set", :skip_in_ci do
      it "returns an array" do
        result = fetcher.fetch
        expect(result).to be_an(Array)
      end

      it "returns jobs with required keys" do
        result = fetcher.fetch
        result.each do |job|
          expect(job).to include(:id, :source, :title, :company, :location, :url, :salary, :posted_at, :fetched_at)
          expect(job[:source]).to eq("ApifyIndeed")
        end
      end
    end
  end
end
