# frozen_string_literal: true

require_relative "base"

module Roseflow
  module OpenAI
    module Operations
      # Image edit operation.
      #
      # Given a prompt and/or an input image, the model will generate
      # a new image. This operation creates an edited or extended image
      # given an original image and a prompt.
      #
      # See https://platform.openai.com/docs/api-reference/images for
      # more information.
      #
      # Many of the attributes are actually optional for the API, but we
      # provide defaults to them. This may change in the future.
      class ImageEdit < Dry::Struct
        transform_keys(&:to_sym)

        attribute :image, Types::String
        attribute? :mask, Types::String
        attribute :prompt, Types::String
        attribute :n, Types::Integer.default(1)
        attribute :size, Types::String.default("1024x1024")
        attribute :response_format, Types::String.default("url")
        attribute? :user, Types::String

        attribute :path, Types::String.default("/v1/images/edits")

        def body
          to_h.except(:path)
        end
      end
    end
  end
end
