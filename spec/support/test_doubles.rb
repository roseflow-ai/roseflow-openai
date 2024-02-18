# frozen_string_literal: true

require "omnes"

module TestDoubles
  class StreamEventSubscriber
    include Omnes::Subscriber

    handle :stream_event, with: :handler
    handle :model_streaming_event, with: :handler

    def handler(event)
      puts "STREAM EVENT: #{event.body}"
    end
  end
end