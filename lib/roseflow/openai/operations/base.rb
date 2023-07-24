# frozen_string_literal: true

module Roseflow
  module OpenAI
    module Operations
      class Base < Dry::Struct
        transform_keys(&:to_sym)

        attribute :model, Types::String

        def body
          to_h.except(:path)
        end
      end
    end
  end
end
