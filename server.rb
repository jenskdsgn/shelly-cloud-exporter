# frozen_string_literal: true

# Bundler setup
require 'rubygems'
require 'bundler/setup'
require 'time'

# Webserver serving metrics
require 'webrick'

require_relative './shelly_cloud_client'

PORT = 9112
AUTHORIZATION_KEY = ENV.fetch('AUTHORIZATION_KEY')
DEVICE_ID = ENV.fetch('DEVICE_IDS').split(",").map(&:strip).first
SERVER_URL = ENV.fetch('SERVER_URL')

client = ShellyCloudClient.new(server_url: SERVER_URL, auth_key: AUTHORIZATION_KEY)

class MetricsServlet < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, client)
    super(server)
    @client = client
  end

  def do_GET(_request, response)
    metrics = @client.fetch_device_status(DEVICE_ID)

    response.status = 200
    response.content_type = 'text/plain'

    return if metrics[:online] && Time.now - Time.parse(metrics[:last_update] + " UTC") > 600 #s
    response.body = <<~BODY
      # HELP shelly_cloud_device Current Power
      # TYPE shelly_cloud_device gauge
      "shelly_cloud_device{device_id=\"#{DEVICE_ID}\"} #{metrics[:power_watts]}"

      # HELP shelly_cloud_device Current Wifi rssi
      # TYPE shelly_cloud_device gauge
      "shelly_cloud_device{device_id=\"#{DEVICE_ID}\"} #{metrics[:wifi_rssi]}"
    BODY
  end
end

server = WEBrick::HTTPServer.new(Port: PORT)

server.mount '/metrics', MetricsServlet, client

trap 'INT' do
  server.shutdown
end

server.start
