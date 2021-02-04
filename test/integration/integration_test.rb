# frozen_string_literal: true

require 'test/unit'
require 'net/http'

class TestFluentIntegration < Test::Unit::TestCase
  def setup
    puts `cd test/integration/fixtures && docker-compose up -d --force-recreate --build`
    puts 'waiting 5s for integration test to start'
    sleep 5
  end

  def teardown
    puts `cd test/integration/fixtures && docker-compose down`
  end

  def test_integration
    puts 'sending logs'
    uri = URI.parse('http://localhost:8080/dt.match')
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })

    req.body = '[{"foo":"bar"},{"abc":"def"},{"xyz":"123"},{"abc":"def"},{"xyz":"123"},{"abc":"def"},{"xyz":"123"}]'
    http.request(req)

    puts 'waiting 10s for output plugin to flush'
    sleep 10

    logs = `docker logs fixtures_logsink_1`

    line1 = '[{"foo":"bar"},{"abc":"def"},{"xyz":"123"},{"abc":"def"},{"xyz":"123"}]'
    line2 = '[{"abc":"def"},{"xyz":"123"}]'
    assert_equal("#{line1}\n#{line2}\n", logs)
  end
end