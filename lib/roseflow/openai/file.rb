# frozen_string_literal: true

require "roseflow"

module Roseflow
  module OpenAI
    class File < Dry::Struct
      transform_keys(&:to_sym)

      attribute :id, Types::String
      attribute :object, Types::String
      attribute :bytes, Types::Integer
      attribute :created_at, Types::Integer
      attribute :filename, Types::String
      attribute :purpose, Types::String
      attribute :status, Types::String
      attribute :status_details, Types::StringOrNil

      def content
        @content ||= Roseflow::Registry.get(:providers).find(:openai).get_file_content(id)
      end
    end
  end
end
