# frozen_string_literal: true

module Roseflow
  module OpenAI
    module Operations
      class Base < Dry::Struct
        transform_keys(&:to_sym)

        attribute :model, Types::String

        def excluded_keys
          [:path]
        end

        def body
          to_h.except(*excluded_keys)
        end
      end
    end
  end
end
