# frozen_string_literal: true

require "dry-struct"

module Roseflow
  module OpenAI
    class ModelPermission < Dry::Struct
      transform_keys(&:to_sym)

      attribute :id, Types::String
      attribute :object, Types::String
      attribute :created, Types::Integer
      attribute :allow_create_engine, Types::Bool
      attribute :allow_sampling, Types::Bool
      attribute :allow_logprobs, Types::Bool
      attribute :allow_search_indices, Types::Bool
      attribute :allow_view, Types::Bool
      attribute :allow_fine_tuning, Types::Bool
      attribute :organization, Types::String
      attribute :is_blocking, Types::Bool

      alias_method :finetuneable?, :allow_fine_tuning
      alias_method :is_blocking?, :is_blocking
    end # ModelPermission
  end
end