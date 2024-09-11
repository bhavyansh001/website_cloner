require 'spec_helper'
require 'website_cloner/utils'
require 'stringio'

RSpec.describe WebsiteCloner::Utils do
  describe '.logger' do
    it 'returns a Logger instance' do
      expect(described_class.logger).to be_a(Logger)
    end

    it 'sets a custom formatter' do
      logger = described_class.logger
      expect(logger.formatter).to be_a(Proc)
    end
  end
end
