# frozen_string_literal: true

require "roseflow/chat/message"

module Roseflow
  module OpenAI
    MessagesArrayError = Class.new(StandardError)
    MessagesArrayInsufficientMessageCountError = Class.new(StandardError)
    MessagesInputNotHashesError = Class.new(StandardError)

    class ChatMessageBuilder
      def initialize(messages)
        @messages = messages
      end

      def call
        validate_messages
        roles_specified = @messages.all? { |message| message.key?(:role) }

        return build_messages if roles_specified
        return build_messages_without_roles unless roles_specified
      end

      def validate_messages
        raise MessagesArrayError unless @messages.is_a?(Array)
        raise MessagesArrayInsufficientMessageCountError unless @messages.count > 1
        raise MessagesInputNotHashesError unless @messages.all? { |message| message.is_a?(Hash) }
      end

      def build_messages
        @messages.map do |message|
          build_message(message[:role], message[:content])
        end
      end

      def build_message(role, content)
        case role
        when "system"
          Roseflow::Chat::SystemMessage.from(content)
        when "user"
          Roseflow::Chat::UserMessage.from(content)
        when "assistant"
          Roseflow::Chat::ModelMessage.from(content)
        end
      end

      def build_messages_without_roles
        messages_array = []
        messages_array << build_message("system", @messages.first[:content])

        @messages[1..-1].each_with_index do |message, index|
          role = index.even? ? "user" : "assistant"
          messages_array << build_message(role, message[:content])
        end

        messages_array
      end
    end
  end
end