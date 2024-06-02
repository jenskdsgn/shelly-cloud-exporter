require 'uri'
require 'faraday'

class ShellyCloudClient
  def initialize(server_url:, auth_key:)
    @auth_key = auth_key
    @server_url = server_url
  end

  def fetch_device_status(device_id)
    url = build_resource_url("/device/status", "id=#{device_id}&auth_key=#{@auth_key}")
    response = Faraday.get(url, nil)
    payload = JSON.parse(response.body, symbolize_names: true)

    # {
    #   :isok=>true,
    #   :data=>{
    #     :online=>true,
    #     :device_status=>{
    #       :_updated=>"2024-06-02 18:42:26",
    #       :relays=>[
    #         {:ison=>true,
    #         :has_timer=>false,
    #         :timer_started=>0,
    #         :timer_duration=>0,
    #         :timer_remaining=>0,
    #         :overpower=>false,
    #         :source=>"cloud"}],
    #       :cloud=>{:enabled=>true,
    #       :connected=>true},
    #       :overtemperature=>false,
    #       :uptime=>628570,
    #       :mac=>"3CE90ED7F7E4",
    #       :fs_free=>166162,
    #       :wifi_sta=>{
    #         :connected=>true,
    #         :ssid=>"Kimpernweg",
    #         :ip=>"192.168.1.169",
    #         :rssi=>-76
    #       },
    #       :has_update=>true,
    #       :meters=>[
    #         {:power=>29.59, :overpower=>0,  :is_valid=>true,:timestamp=>1717360944,:counters=>[31.15, 32.371, 33.813], :total=>1172296}
    #       ],
    #       :fs_size=>233681,
    #       :unixtime=>1717351876,
    #       :time=>"20:42",
    #       :update=>{:status=>"pending",
    #       :has_update=>true,
    #       :new_version=>"20230913-113421/v1.14.0-gcb84623",
    #       :old_version=>"20230503-101129/v1.13.0-g9aed950",
    #       :beta_version=>"20231107-164219/v1.14.1-rc1-g0617c15"},
    #       :actions_stats=>{:skipped=>0}, :tmp=>{:tC=>27.85, :tF=>82.12, :is_valid=>true},
    #       :serial=>17852,
    #       :mqtt=>{:connected=>false},
    #       :cfg_changed_cnt=>6, :ram_free=>40788, :temperature=>27.85, :ram_total=>52056}}}

    {
      online: payload.dig(:data, :online),
      wifi_rssi: payload.dig(:data, :device_status, :wifi_sta, :rssi),
      last_update: payload.dig(:data, :device_status, :_updated),
      power_watts: payload.dig(:data, :device_status, :meters).first[:power]
    }
  end

  private

  def build_resource_url(path, query)
    uri = URI.parse(@server_url)
    uri.path = path
    uri.query = query
    uri
  end
end
