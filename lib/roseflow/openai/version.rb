# frozen_string_literal: true

module Roseflow
  module OpenAI
    def self.gem_version
      Gem::Version.new VERSION::STRING
    end

    module VERSION
      MAJOR = 0
      MINOR = 2
      PATCH = 5
      PRE = nil

      STRING = [MAJOR, MINOR, PATCH, PRE].compact.join(".")
    end
  end
end
