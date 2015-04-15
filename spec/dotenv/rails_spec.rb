require "spec_helper"
ENV["RAILS_ENV"] = "test"
require "rails"
require "dotenv/rails"

describe Dotenv::Railtie do
  # Fake watcher for Spring
  class SpecWatcher
    attr_reader :items

    def initialize
      @items = []
    end

    def add(*items)
      @items |= items
    end
  end

  before do
    allow(Rails).to receive(:version)
      .and_return "4.0.0"
    allow(Rails).to receive(:root)
      .and_return Pathname.new(File.expand_path("../../fixtures", __FILE__))
    allow(Rails).to receive(:env)
      .and_return ActiveSupport::StringInquirer.new('test')
    Rails.application = double(:application)
    Spring.watcher = SpecWatcher.new
  end

  after do
    # Reset
    Spring.watcher = nil
    Rails.application = nil
  end

  context "before_configuration" do
    it "calls #load" do
      expect(Dotenv::Railtie.instance).to receive(:load)
      ActiveSupport.run_load_hooks(:before_configuration)
    end
  end

  context "load" do
    before { Dotenv::Railtie.load }

    it "watches .env with Spring" do
      expect(Spring.watcher.items).to include(Rails.root.join(".env").to_s)
    end

    it "watches other loaded files with Spring" do
      path = fixture_path("plain.env")
      Dotenv.load(path)
      expect(Spring.watcher.items).to include(path)
    end

    it "loads Dotenv::ToLoad" do
      existing_to_load = Dotenv::Railtie.instance.to_load.to_a
      existing_to_load = existing_to_load.select{ |i| File.exists?(i) }
      expect(Spring.watcher.items).to eql(existing_to_load)
    end

    it "loads .env.local before .env" do
      expect(ENV["DOTENV"]).to eql("local")
    end

    context "when Rails.root is nil" do
      before do
        allow(Rails).to receive(:root).and_return(nil)
      end

      it "falls back to RAILS_ROOT" do
        ENV["RAILS_ROOT"] = "/tmp"
        expect(Dotenv::Railtie.root.to_s).to eql("/tmp")
      end
    end
  end
end
