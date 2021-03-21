require 'minitest/autorun'
require_relative '../lib/crawler'
require 'webrick'

class Crawler::TestCase < Minitest::Test
  def before_setup
    super
  end
end

# Runs a directory as a webrick server on a locally accessible port (3000)
class FakeSite
  def initialize(fixture_path)
    @server = nil
    @thread = Thread.new do
      Thread.abort_on_exception = true
      log_file = File.open("log/fake_server.log", "a")
      @server = WEBrick::HTTPServer.new(
        Port: 3000,
        DocumentRoot: "test/fixtures/#{fixture_path}",
        AccessLog: [
          [log_file, WEBrick::AccessLog::COMMON_LOG_FORMAT]
        ],
        Logger: WEBrick::Log.new(log_file)
      )
      @server.start
    end

    # wait for boot
    loop do
      break if !@server.nil? && @server.status == :Running
      sleep 0.001
    end
  end

  def url
    "http://localhost:3000/"
  end

  def stop
    @server.shutdown
    @thread.join
  end
end