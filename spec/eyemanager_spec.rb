require "spec_helper"

RSpec.describe EyeManager do
  it "has a version number" do
    expect(EyeManager::VERSION).not_to be nil
  end

  describe ".start" do
    it "requires the :application param" do
      expect{EyeManager.start config: 'spec/eye.test.rb'}
          .to raise_error /application is required/
    end

    context "when called with :config" do
      it "loads config, and raises exception if the eye load command fails" do
        allow(EyeManager)
            .to receive(:`)
                    .with("eye load spec/eye.test.rb")
                    .and_return("Config not loaded")
        expect{EyeManager.start config: 'spec/eye.test.rb',
                                application: 'test'}
            .to raise_error EyeManager::EyeLoadFailed,
                            /Eye load failed to load config. Command: eye load spec\/eye.test.rb./
      end

      it "system calls eye load :config which returns 'Config loaded'" do
        allow(EyeManager)
            .to receive(:`)
                    .with("eye load spec/eye.test.rb")
                    .and_return("Config loaded")
        allow(EyeManager)
            .to receive(:`)
                    .with("eye start test")
                    .and_return("command :start sent to [test]")
        EyeManager.start config: 'spec/eye.test.rb',
                         application: 'test'
      end
    end

    context "when called without :config" do
      it "doesn't try to load config" do
        expect(EyeManager)
            .to_not receive(:`)
                    .with("eye load spec/eye.test.rb")
        allow(EyeManager)
            .to receive(:`)
                    .with("eye start test")
                    .and_return("command :start sent to [test]")
        EyeManager.start application: 'test'
      end
    end

    it "calls eye start referencing the :application" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye load spec/eye.test.rb")
                  .and_return("Config loaded")
      allow(EyeManager)
          .to receive(:`)
                  .with("eye start test")
                  .and_return("command :start sent to [test]")
      EyeManager.start config: 'spec/eye.test.rb',
                       application: 'test'
    end

    it "raises exception if eye start system call does not output expected message" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye load spec/eye.test.rb")
                  .and_return("Config loaded")
      allow(EyeManager)
          .to receive(:`)
                  .with("eye start test")
                  .and_return("failed to start")
      expect{EyeManager.start config: 'spec/eye.test.rb',
                       application: 'test'}
          .to raise_exception /Eye start failed. Command: eye start test./
    end
  end

  describe ".stop" do
    it "requires the :application param" do
      expect{EyeManager.stop }
          .to raise_error /application is required/
    end

    it "requires the :process param" do
      expect{EyeManager.stop application: 'test'}
          .to raise_error /process is required/
    end

    it "raises exception if eye stop system call does not output expected message" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye stop test:myproc")
                  .and_return("failed to stop")
      expect{EyeManager.stop application: 'test',
                             process: 'myproc'}
          .to raise_exception /Eye stop failed. Command: eye stop test:myproc./
    end

    context "when :group is included as input" do
      it "calls eye stop referencing the application:group:process" do
        allow(EyeManager)
            .to receive(:`)
                    .with("eye stop test:testgroup:myproc")
                    .and_return("command :stop sent to [test:testgroup:myproc]")
        EyeManager.stop application: 'test',
                        group: 'testgroup',
                        process: 'myproc'
      end
    end

    context "when :group is not included as input" do
      it "calls eye stop referencing the application:process" do
        allow(EyeManager)
            .to receive(:`)
                    .with("eye stop test:myproc")
                    .and_return("command :stop sent to [test:myproc]")
        EyeManager.stop application: 'test',
                        process: 'myproc'
      end
    end
  end

  describe ".status" do
    it "requires the :process param" do
      expect{EyeManager.status }
          .to raise_error /process is required/
    end

    it "returns the status for a queried process" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return(eye_status_json_sample)
      expect(EyeManager.status process: 'sample').to eq 'up'
    end

    it "returns the status for a queried application:process" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return(eye_status_json_sample)
      expect(EyeManager.status application: 'test',
                               process: 'sample').to eq 'up'
    end

    it "returns the status for a queried application:group:process" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return(eye_status_json_sample)
      expect(EyeManager.status application: 'test2',
                               group: 'samples',
                               process: 'sample').to eq 'starting'
    end

    it "returns unknown if eye doesn't know about the queried process" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return(eye_status_json_sample)
      expect(EyeManager.status application: 'test',
                               process: 'sampleunknown').to eq 'unknown'
    end

    it "returns unknown if the eye command output is not JSON" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return("this is not json")
      expect(EyeManager.status application: 'test',
                               process: 'sample').to eq 'unknown'
    end
  end

  describe ".destroy" do
    it "raises exception if eye stop system call does not output expected message" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye q -s")
                  .and_return("unexpected output message")
      expect{EyeManager.destroy}
          .to raise_exception /Eye destroy failed. Command: eye q -s./
    end

    it "calls eye q -s and does not throw exception when " +
           "command output contains 'Eye quit'" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye q -s")
                  .and_return("Eye quit")
      EyeManager.destroy
    end

    it "calls eye q -s and does not throw exception when " +
           "command output contains 'socket(*) not found'" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye q -s")
                  .and_return("socket(/home/resrev/.eye/sock) not found")
      EyeManager.destroy
    end
  end

  describe ".list_apps" do
    it "issues eye i -j command to system and extracts the apps from returned json" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return(eye_status_json_sample)
      expect(EyeManager.list_apps).to eq ['test', 'test2']
    end

    it "returns an empty array if eye i -j returns invalid json" do
      allow(EyeManager)
          .to receive(:`)
                  .with("eye i -j")
                  .and_return("invalid json")
      expect(EyeManager.list_apps).to eq []
    end
  end

  def eye_status_json_sample
    %Q({
        "subtree": [
          {
            "name": "test",
            "type": "application",
            "subtree": [
              {
                "name": "__default__",
                "type": "group",
                "subtree": [
                  {
                    "name": "sample",
                    "state": "up",
                    "type": "process",
                    "resources": {
                      "memory": 14872576,
                      "cpu": 0,
                      "start_time": 1503188982,
                      "pid": 6261
                    },
                    "state_changed_at": 1503188985,
                    "state_reason": "monitor by user"
                  }
                ]
              }
            ],
            "debug": null
          },
          {
            "name": "test2",
            "type": "application",
            "subtree": [
              {
                "name": "samples",
                "type": "group",
                "subtree": [
                  {
                    "name": "sample",
                    "state": "starting",
                    "type": "process",
                    "resources": {
                      "memory": 14774272,
                      "cpu": 0,
                      "start_time": 1503188995,
                      "pid": 6276
                    },
                    "state_changed_at": 1503188997,
                    "state_reason": "monitor by user"
                  }
                ]
              }
            ],
            "debug": null
          }
        ]
      })
  end
end
