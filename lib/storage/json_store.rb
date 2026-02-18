# frozen_string_literal: true

require "fileutils"
require "json"

module Storage
  class JsonStore
    def initialize(path:)
      @path = path
    end

    def load
      return [] unless File.exist?(@path)

      JSON.parse(File.read(@path))
    rescue JSON::ParserError
      []
    end

    def save(jobs)
      FileUtils.mkdir_p(File.dirname(@path)) if File.dirname(@path) != "."
      File.write(@path, JSON.pretty_generate(jobs))
    end
  end
end
