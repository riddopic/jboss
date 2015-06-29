# Encoding: utf-8

require_relative 'spec_helper'

describe 'jboss::default' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(
            platform:  platform,
            version:   version,
            log_level: LOG_LEVEL
          ) do |node|
          end.converge(described_recipe)
        end
      end
    end
  end
end
