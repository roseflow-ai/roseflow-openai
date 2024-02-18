
module Roseflow
  module OpenAI
    class Assistant
      def initialize(model)
        @model = model
      end

      def create_session(prompt, **params)
        response = @client.create_completion(prompt: prompt, model: @model, **params)
        response["id"]
      end

      def continue_session(session_id, **params)
        response = @client.completion(session_id: session_id, **params)
        response["choices"][0]["text"]
      end

      def delete_session(session_id)
        @client.delete_completion(session_id: session_id)
      end
    end
  end
end
