# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "rails_jobs/config"
require "rails_jobs/runner"
require "fetchers/base_fetcher"
require "fetchers/remotive_fetcher"
require "fetchers/arbeitnow_fetcher"
require "fetchers/himalayas_fetcher"
require "fetchers/the_muse_fetcher"
require "notifiers/discord_notifier"
require "storage/json_store"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end
