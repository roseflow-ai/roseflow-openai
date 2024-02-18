module Roseflow
  module OpenAI
    class AssistantRepository
      def initialize(provider)
        @provider = provider
        @assistants = provider.assistants
        @named_assistants = {}
      end

      def register(name, assistant)
        @assistants[assistant.id] = assistant
        @named_assistants[name] = assistant
      end

      def find(name)
        @named_assistants[name]
      end

      def find_by_id(id)
        @assistants[id]
      end
    end
  end
end