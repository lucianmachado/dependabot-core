# frozen_string_literal: true
require "spec_helper"
require "bump/dependency"
require "bump/dependency_file"
require "bump/file_updaters/php/composer"
require_relative "../shared_examples_for_file_updaters"

RSpec.describe Bump::FileUpdaters::Php::Composer do
  it_behaves_like "a dependency file updater"

  let(:updater) do
    described_class.new(
      dependency_files: [composer_json, lockfile],
      dependency: dependency,
      github_access_token: "token"
    )
  end

  let(:composer_json) do
    Bump::DependencyFile.new(content: composer_body, name: "composer.json")
  end
  let(:composer_body) { fixture("php", "composer_files", "exact_version") }

  let(:lockfile_body) { fixture("php", "lockfiles", "exact_version") }
  let(:lockfile) do
    Bump::DependencyFile.new(name: "composer.lock", content: lockfile_body)
  end

  let(:dependency) do
    Bump::Dependency.new(
      name: "monolog/monolog",
      version: "1.22.1",
      package_manager: "composer"
    )
  end
  let(:tmp_path) { Bump::SharedHelpers::BUMP_TMP_DIR_PATH }

  before { Dir.mkdir(tmp_path) unless Dir.exist?(tmp_path) }

  describe "#updated_dependency_files" do
    subject(:updated_files) { updater.updated_dependency_files }

    pending "doesn't store the files permanently" do
      expect { updated_files }.to_not(change { Dir.entries(tmp_path) })
    end

    pending "returns DependencyFile objects" do
      updated_files.each { |f| expect(f).to be_a(Bump::DependencyFile) }
    end

    pending { expect { updated_files }.to_not output.to_stdout }
    pending(:length) { is_expected.to eq(2) }

    describe "the updated composer_file" do
      subject(:updated_composer_file) do
        updated_files.find { |f| f.name == "composer.json" }
      end

      pending(:content) do
        is_expected.to include "\"monolog/monolog\": \"1.22.1\""
      end
      pending(:content) do
        is_expected.to include "\"symfony/polyfill-mbstring\": \"1.0.1\""
      end

      context "when the minor version is specified" do
        let(:composer_body) do
          fixture("php", "composer_files", "minor_version")
        end

        pending(:content) do
          is_expected.to include "\"monolog/monolog\": \"1.22.x\""
        end
      end
    end

    describe "the updated lockfile" do
      subject(:updated_lockfile) do
        updated_files.find { |f| f.name == "composer.lock" }
      end

      pending "has details of the updated item" do
        expect(updated_lockfile.content).
          to include("\"version\": \"1.22.1\"")
      end
    end
  end
end
