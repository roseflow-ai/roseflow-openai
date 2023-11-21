# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/module/delegation"

module Roseflow
  module OpenAI
    class ModelRepository
      attr_reader :models

      delegate :each, :all, to: :models

      def initialize(provider)
        @provider = provider
        @models = provider.client.models
      end

      # Finds a model by name.
      #
      # @param name [String] Name of the model
      def find(name)
        @models.select { |model| model.name == name }.first
      end

      # Returns all models that are chattable.
      def chattable
        @models.select(&:chattable?)
      end

      # Returns all models that are completionable.
      def completionable
        @models.select(&:completionable?)
      end

      # Returns all models that are support edits.
      def editable
        @models.select(&:editable?)
      end

      # Returns all models that are support embeddings.
      def embeddable
        @models.select(&:embeddable?)
      end
    end # ModelRepository
  end # OpenAI
end # Roseflow
