# frozen_string_literal: true

require "spec_helper"
require "roseflow"

module Roseflow
  module OpenAI
    RSpec.describe Client do
      let(:config) { Roseflow::OpenAI::Config.new }
      let(:model) { Roseflow::Registry.get(:models).find("gpt-3.5-turbo") }
      let(:provider) { Roseflow::Registry.get(:providers).find(:openai) }
      let(:operation_options) do
        {
          model: "gpt-3.5-turbo",
          messages: [{ role: "system", content: "You are a helpful assistant." }, { role: "user", content: "Count from 1 to 5."} ],
          stream_events: true,
          stream: true
        }
      end
      let(:operation) { Roseflow::OpenAI::Operations::Chat.new(operation_options) }

      describe "stream events" do
        let(:client) { described_class.new(config, provider) }
        let(:event_bus) { Roseflow::Registry.get(:events) }

        before do
          event_bus.register(:stream_event)
        end

        it "streams SSE chunks as events" do
          subscriber = TestDoubles::StreamEventSubscriber.new
          subscriber.subscribe_to(event_bus)
          response = client.post(operation)
          expect(response).to be_a Faraday::Response
        end
      end
    end
  end
end