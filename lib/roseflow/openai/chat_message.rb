# frozen_string_literal: true

require "roseflow/types"
require "roseflow/chat/message"

module Roseflow
  module OpenAI
    class ChatMessage < Roseflow::Chat::Message
      attribute? :function_call, Types::OpenAI::FunctionCallObject
    end
  end
end
