# frozen_string_literal: true

require "omnes"

module TestDoubles
  class StreamEventSubscriber
    include Omnes::Subscriber

    handle :streaming_event, with: :handler

    def handler(event)
      puts "STREAM EVENT: #{event.payload.fetch(:body)}"
    end
  end
end