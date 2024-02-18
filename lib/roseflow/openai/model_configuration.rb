# frozen_string_literal: true

require "dry-struct"

require "roseflow/openai/model_permission"

module Roseflow
  module OpenAI
    class ModelConfiguration < Dry::Struct
      transform_keys(&:to_sym)

      attribute :id, Types::String
      attribute :created, Types::Integer
      attribute? :permission, Types::Array.of(ModelPermission)
      attribute? :root, Types::String
      attribute? :parent, Types::String | Types::Nil

      alias_method :name, :id

      def permissions
        permission.first
      end

      delegate :finetuneable?, :is_blocking?, to: :permissions
    end # ModelConfiguration
  end
end