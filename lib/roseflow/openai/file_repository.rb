# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/module/delegation"

module Roseflow
  module OpenAI
    class FileRepository
      attr_reader :files

      delegate :each, to: :files

      def initialize(provider)
        @provider = provider
        @files = provider.client.files
      end

      def upload(filename, io)
        @provider.client.upload(filename, io)
      end

      def get(filename)
        @provider.client.get_file(filename)
      end
    end
  end
end
