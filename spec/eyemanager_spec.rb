require "spec_helper"

RSpec.describe EyeManager do
  it "has a version number" do
    expect(EyeManager::VERSION).not_to be nil
  end

  before :all do
    EyeManager.destroy
  end

  after :all do
    EyeManager.destroy
  end

  describe ".start" do
    it "should require the :application param" do
      expect{EyeManager.start config: 'spec/eye.test.rb'}
          .to raise_error /application is required/
    end

    it "should load an eye config and start eye" do
      EyeManager.start config: 'spec/eye.test.rb', application: 'test'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
    end

    it "can load a second config without affecting existing running apps" do
      EyeManager.start config: 'spec/eye.test2.rb', application: 'test2'
      sleep 0.5
      expect(EyeManager.status(application: 'test2', group: 'samples',
                               process: 'sample'))
          .to match /up|starting/
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
    end

    it "can start an eye app without loading config " +
           "(assuming config already loaded)" do
      EyeManager.stop application: 'test', process: 'sample'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /unmonitored/
      expect(EyeManager.status(application: 'test2', group: 'samples',
                               process: 'sample'))
          .to match /up|starting/
      EyeManager.start application: 'test'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
      expect(EyeManager.status(application: 'test2', group: 'samples',
                               process: 'sample'))
          .to match /up|starting/
    end
  end

  describe ".status" do
    it "should require the :process param" do
      expect{EyeManager.status application: 'test'}
          .to raise_error /process is required/
    end

    it "should return unknown if eye does not know about the " +
           "application, group and/or process" do
      expect(EyeManager.status(application: 'testunknown', process: 'sample'))
          .to eq 'unknown'
      expect(EyeManager.status(application: 'test', process: 'sampleunknown'))
          .to eq 'unknown'
    end

    it "should return the status" do
      EyeManager.destroy
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to eq 'unknown'
      EyeManager.start config: 'spec/eye.test.rb', application: 'test'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
    end
  end

  describe ".stop" do
    it "should require the :application param" do
      expect{EyeManager.stop process: 'sample'}
          .to raise_error /application is required/
    end

    it "should require the :process param" do
      expect{EyeManager.stop application: 'test'}
          .to raise_error /process is required/
    end

    it "should stop an application process without affecting other application processes" do
      EyeManager.destroy
      EyeManager.start config: 'spec/eye.test.rb', application: 'test'
      EyeManager.start config: 'spec/eye.test2.rb', application: 'test2'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
      expect(EyeManager.status(application: 'test2', group: 'samples',
                               process: 'sample'))
          .to match /up|starting/
      EyeManager.stop application: 'test2', group: 'samples', process: 'sample'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
      expect(EyeManager.status(application: 'test2', group: 'samples',
                               process: 'sample'))
          .to match /unmonitored/
    end
  end

  describe ".destroy" do
    it "should stop eye" do
      EyeManager.start config: 'spec/eye.test.rb', application: 'test'
      sleep 0.5
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to match /up|starting/
      EyeManager.destroy
      expect(EyeManager.status(application: 'test', process: 'sample'))
          .to eq 'unknown'
    end
  end
  
  describe ".list_apps" do
    it "should list the apps" do
      EyeManager.start config: 'spec/eye.test.rb', application: 'test'
      EyeManager.start config: 'spec/eye.test2.rb', application: 'test2'
      sleep 0.5
      expect(EyeManager.list_apps).to match_array ['test','test2']
    end
  end
end
