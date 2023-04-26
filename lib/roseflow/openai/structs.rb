# frozen_string_literal: true

require "dry-struct"

module Roseflow
  module OpenAI
    # A model instruction struct. Used to pass instructions to the model.
    # @param instruction [String] The instruction that tells the model how to edit the prompt.
    # @param input [String] The input text to use as a starting point for the edit.
    # @param n [Integer] Number of results to be returned by the model.
    # @param temperature [Float] Sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
    # @param top_p [Float] An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass.
    class EditModelInstruction < Dry::Struct
      attribute :instruction, Types::String
      attribute :input, Types::String.default("")
      attribute :n, Types::Integer.default(1)
      attribute :temperature, Types::Float.default(1)
      attribute :top_p, Types::Float.default(1)
    end
  end
end