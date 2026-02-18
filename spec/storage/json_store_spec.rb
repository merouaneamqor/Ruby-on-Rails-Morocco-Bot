# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Storage::JsonStore do
  let(:tmp_path) { Tempfile.new(["jobs", ".json"]).path }
  let(:store) { described_class.new(path: tmp_path) }

  after { File.unlink(tmp_path) if File.exist?(tmp_path) }

  describe "#load" do
    it "returns empty array when file does not exist" do
      store2 = described_class.new(path: "/nonexistent/path/jobs.json")
      expect(store2.load).to eq([])
    end

    it "returns parsed array when file exists" do
      File.write(tmp_path, '[{"id":"1","title":"Rails Dev"}]')
      expect(store.load).to eq([{ "id" => "1", "title" => "Rails Dev" }])
    end

    it "returns [] on invalid JSON" do
      File.write(tmp_path, "not json")
      expect(store.load).to eq([])
    end
  end

  describe "#save" do
    it "writes JSON to file" do
      jobs = [{ "id" => "1", "title" => "Rails" }]
      store.save(jobs)
      expect(JSON.parse(File.read(tmp_path))).to eq(jobs)
    end
  end
end
