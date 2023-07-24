# frozen_string_literal: true

require_relative "operations/chat"
require_relative "operations/completion"
require_relative "operations/image"
require_relative "operations/image_edit"
require_relative "operations/image_variation"
require_relative "operations/embedding"

module Roseflow
  module OpenAI
    class OperationHandler
      OPERATION_CLASSES = {
        chat: Operations::Chat,
        completion: Operations::Completion,
        embedding: Operations::Embedding,
        image: Operations::Image,
        image_edit: Operations::ImageEdit,
        image_variation: Operations::ImageVariation,
      }

      def initialize(operation, options = {})
        @operation = operation
        @options = options
      end

      def call
        operation_class.new(@options)
      end

      private

      def operation_class
        OPERATION_CLASSES.fetch(@operation) do
          raise ArgumentError, "Invalid operation: #{@operation}"
        end
      end
    end
  end
end
