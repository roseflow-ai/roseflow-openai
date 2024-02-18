require "spec_helper"

require "roseflow/openai/file_repository"

module Roseflow
  module OpenAI
    RSpec.describe File do
      let(:file_json) { JSON.parse(::File.read("spec/fixtures/files/file.json")) }

      describe "Initialization" do
        it "should initialize" do
          expect(described_class.new(file_json)).to be_a(described_class)
        end
      end
    end

    RSpec.describe FileRepository do
      let(:provider) { Roseflow::OpenAI::Provider.new }

      describe "Initialization" do
        it "should initialize" do
          expect { described_class.new(provider) }.not_to raise_error
        end
      end

      describe "Instance Methods" do
        let(:repository) { described_class.new(provider) }

        describe "#upload", skip: true do
          let(:file) { ::File.read("spec/fixtures/files/finetune.jsonl") }
          let(:file) { StringIO.new(::File.read("spec/fixtures/files/finetune.jsonl")) }

          it "should upload a file" do
            VCR.use_cassette("files/upload", record: :new_episodes) do
              expect(repository.upload(file, "finetune.jsonl")).to be_a(OpenAI::File)
            end
          end
        end

        describe "#delete" do
        end

        describe "#get" do
          let(:file_id) { "file-t79QbG3mg5npoEgtrQwEdGec" }

          it "should return a file" do
            VCR.use_cassette("files/get", record: :new_episodes) do
              expect(repository.get(file_id)).to be_a(OpenAI::File)
            end
          end
        end

        describe "file content" do
          let(:file_id) { "file-t79QbG3mg5npoEgtrQwEdGec" }

          it "should return the file content" do
            VCR.use_cassette("files/get_content", record: :new_episodes) do
              content = repository.get(file_id).content
              expect(content).to be_a(String)
            end
          end
        end
      end

      describe "Delegated Methods" do
        describe "#each" do
          let(:repository) { described_class.new(provider) }
          it "should return an Enumerator" do
            expect { repository.each }.not_to raise_error
            expect(repository.each).to be_a(Enumerator)
          end
        end
      end
    end
  end
end
