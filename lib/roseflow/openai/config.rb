# frozen_string_literal: true

require "anyway_config"

module Roseflow
  module OpenAI
    # Configuration class for the OpenAI provider.
    class Config < Anyway::Config
      config_name :openai

      attr_config :api_key, :organization_id

      required :api_key
      required :organization_id

      OPENAI_API_URL        = "https://api.openai.com"
      CHAT_MODELS           = %w(gpt-4 gpt-4-0314 gpt-4-32k gpt-4-32k-0314 gpt-3.5-turbo gpt-3.5-turbo-0301).freeze
      COMPLETION_MODELS     = %w(text-davinci-003 text-davinci-002 text-curie-001 text-babbage-001 text-ada-001 davinci curie babbage ada).freeze
      EDIT_MODELS           = %w(text-davinci-edit-001 code-davinci-edit-001).freeze
      TRANSCRIPTION_MODELS  = %w(whisper-1).freeze
      TRANSLATION_MODELS    = %w(whisper-1).freeze
      FINE_TUNE_MODELS      = %w(davinci curie babbage ada).freeze
      EMBEDDING_MODELS      = %w(text-embedding-ada-002 text-search-ada-doc-001).freeze
      MODERATION_MODELS     = %w(text-moderation-stable text-moderation-latest).freeze
      MAX_TOKENS = {
        "gpt-4": 8192,
        "gpt-4-0314": 8192,
        "gpt-4-32k": 32_768,
        "gpt-4-32k-0314": 32_768,
        "gpt-3.5-turbo": 4096,
        "gpt-3.5-turbo-0301": 4096,
        "text-davinci-003": 4097,
        "text-davinci-002": 4097,
        "code-davinci-002": 8001
      }
    end # Config
  end # OpenAI
end # Roseflow