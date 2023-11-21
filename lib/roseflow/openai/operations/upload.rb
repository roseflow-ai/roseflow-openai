# frozen_string_literal: true

require_relative "base"

module Roseflow
  module OpenAI
    module Operations
      # Image operation.
      #
      # Given a prompt and/or an input image, the model will generate
      # a new image. This operation creates an image given a prompt.
      #
      # See https://platform.openai.com/docs/api-reference/images for
      # more information.
      #
      # Many of the attributes are actually optional for the API, but we
      # provide defaults to them. This may change in the future.
      class Upload < Dry::Struct
        transform_keys(&:to_sym)

        attribute :filename, Types::String
        attribute :purpose, Types::String.default("fine-tune")

        attribute :path, Types::String.default("/v1/files")

        def body
          to_h.except(:path)
        end
      end
    end
  end
end
