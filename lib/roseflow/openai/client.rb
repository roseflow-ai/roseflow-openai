# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "faraday/typhoeus"
require "roseflow/types"
require "roseflow/openai/config"
require "roseflow/openai/model"
require "roseflow/openai/response"

require "roseflow/events/model/streaming_event"

module Roseflow
  module OpenAI
    class Client
      FARADAY_RETRY_OPTIONS = {
        max: 3,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2,
      }

      def initialize(config = Config.new, provider = nil)
        @config = config
        @provider = provider
      end

      # Returns the available models from the API.
      #
      # @return [Array<OpenAI::Model>] the available models
      def models
        response = connection.get("/v1/models")
        body = JSON.parse(response.body)
        body.fetch("data", []).map do |model|
          OpenAI::Model.new(model, self)
        end
      end

      # Posts an operation to the API.
      #
      # @param operation [OpenAI::Operation] the operation to post
      # @yield [String] the streamed API response
      # @return [OpenAI::Response] the API response object if no block is given
      def post(operation, &block)
        response = connection.post(operation.path) do |request|
          request.body = operation.body
          if operation.respond_to?(:stream) && operation.stream
            request.options.on_data = Proc.new do |chunk|
              publish_data_event(chunk, operation.stream_id) if operation.stream_events
              yield chunk if block_given?
            end
          end
        end
        response unless block_given?
      end

      # Creates a chat completion.
      #
      # @param model [Roseflow::OpenAI::Model] the model to use
      # @param messages [Array<String>] the messages to use
      # @param options [Hash] the options to use
      # @return [OpenAI::TextApiResponse] the API response object
      def create_chat_completion(model:, messages:, **options)
        response = connection.post("/v1/chat/completions") do |request|
          request.body = options.merge({
            model: model.name,
            messages: messages,
          })
        end
        ChatResponse.new(response)
      end

      # Creates a chat completion and streams the response.
      #
      # @param model [Roseflow::OpenAI::Model] the model to use
      # @param messages [Array<String>] the messages to use
      # @param options [Hash] the options to use
      # @yield [String] the streamed API response
      # @return [Array<String>] the streamed API response if no block is given
      def streaming_chat_completion(model:, messages:, **options, &block)
        streamed = []
        connection.post("/v1/chat/completions") do |request|
          options.delete(:streaming)
          request.body = options.merge({
            model: model.name,
            messages: messages,
            stream: true,
          })
          request.options.on_data = Proc.new do |chunk|
            yield streaming_chunk(chunk) if block_given?
            streamed << chunk unless block_given?
          end
        end
        streamed unless block_given?
      end

      # Creates a text completion for the provided prompt and parameters.
      #
      # @param model [Roseflow::OpenAI::Model] the model to use
      # @param prompt [String] the prompt to use
      # @param options [Hash] the options to use
      # @return [OpenAI::TextApiResponse] the API response object
      def create_completion(model:, prompt:, **options)
        response = connection.post("/v1/completions") do |request|
          request.body = options.merge({
            model: model.name,
            prompt: prompt,
          })
        end
        CompletionResponse.new(response)
      end

      # Creates a text completion for the provided prompt and parameters and streams the response.
      #
      # @param model [Roseflow::OpenAI::Model] the model to use
      # @param prompt [String] the prompt to use
      # @param options [Hash] the options to use
      # @yield [String] the streamed API response
      # @return [Array<String>] the streamed API response if no block is given
      def streaming_completion(model:, prompt:, **options, &block)
        streamed = []
        connection.post("/v1/completions") do |request|
          request.body = options.merge({
            model: model.name,
            prompt: prompt,
            stream: true,
          })
          request.options.on_data = Proc.new do |chunk|
            yield streaming_chunk(chunk) if block_given?
            streamed << chunk unless block_given?
          end
        end
        streamed unless block_given?
      end

      # Given a prompt and an instruction, the model will return an edited version of the prompt.
      #
      # @param model [String] the model to use
      # @param instruction [String] the instruction to use
      # @param options [Hash] the options to use
      # @return [OpenAI::TextApiResponse] the API response object
      def create_edit(model:, instruction:, **options)
        response = connection.post("/v1/edits") do |request|
          request.body = options.merge({
            model: model.name,
            instruction: instruction,
          })
        end
        EditResponse.new(response)
      end

      def create_image(prompt:, **options)
        ImageApiResponse.new(
          connection.post("/v1/images/generations") do |request|
            request.body = options.merge(prompt: prompt)
          end
        )
      end

      # Creates an embedding vector representing the input text.
      #
      # @param model [Roseflow::OpenAI::Model] the model to use
      # @param input [String] the input text to use
      # @return [OpenAI::EmbeddingApiResponse] the API response object
      def create_embedding(model:, input:)
        EmbeddingApiResponse.new(
          connection.post("/v1/embeddings") do |request|
            request.body = {
              model: model.name,
              input: input,
            }
          end
        )
      end

      private

      attr_reader :config, :provider

      # The connection object used to make requests to the API.
      def connection
        @connection ||= Faraday.new(
          url: Config::OPENAI_API_URL,
          headers: {
            # "Content-Type" => "application/json",
            "OpenAI-Organization" => config.organization_id,
          },
        ) do |faraday|
          faraday.request :authorization, "Bearer", -> { config.api_key }
          faraday.request :json
          faraday.request :retry, FARADAY_RETRY_OPTIONS
          faraday.adapter :typhoeus
        end
      end

      # Parses streaming chunks from the API response.
      #
      # @param chunk [String] the chunk to parse
      # @return [String] the parsed chunk
      def streaming_chunk(chunk)
        return chunk unless chunk.match(/{.*}/)
        chunk.scan(/{.*}/).map do |json|
          JSON.parse(json).dig("choices", 0, "delta", "content")
        end.join("")
      end

      def publish_data_event(chunk, stream_id)
        chunk.scan(/{.*}/).map do |event|
          Roseflow::Registry.get(:events).publish(
            Roseflow::Events::Model::StreamingEvent.new(
              body: event,
              stream_id: stream_id
            )
          )
        end
      end
    end # Client
  end # OpenAI
end # Roseflow
