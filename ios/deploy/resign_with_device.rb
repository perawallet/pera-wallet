#!/usr/bin/env ruby

require 'spaceship'
require "fastlane_core"
require 'faraday'
require 'faraday_middleware'
require 'plist'
require 'openssl'
require 'digest/sha1'
require 'base64'

CYPHER_HASH = "4c92b22f6cc742d1b7fa6bc830e917ec"
CYPHER_SALT = "5659ad799f814e049136b5aa18dd1255"

TRYOUTS_API_TESTERS_TEMPLATE = "https://api.tryouts.io/v1/applications/%s/testers/"

team_id = nil
app_name = nil
bundle_id = nil
tryouts_app_id = nil
tryouts_token = nil
provision_output_path = nil
itunes_token = nil
profile_name = "#{app_name} Ad Hoc"

ARGV.each do |value|
  args = value.split("=")

  case args[0]
  when "itunes-token"
    itunes_token = args[1]
  when "team-id"
    team_id = args[1]
  when "app-name"
    app_name = args[1]
  when "profile-name"
    profile_name = args[1]
  when "bundle-identifier"
    bundle_id = args[1]
  when "tryouts-app-id"
    tryouts_app_id = args[1]
  when "tryouts-token"
    tryouts_token = args[1]
  when "provision-output-path"
    provision_output_path = args[1]
  else
    puts "Unknown parameter", args[0]
  end
end

puts "Generating profile for #{bundle_id}"

url = TRYOUTS_API_TESTERS_TEMPLATE % tryouts_app_id
connection = Faraday.new(url: url) do |builder|
  builder.request :url_encoded
  builder.response :json, content_type: /\bjson$/
  builder.use FaradayMiddleware::FollowRedirects
  builder.adapter Faraday.default_adapter
end

response = connection.get do |req|
  req.headers['Authorization'] = tryouts_token
end

payload = response.body
tryouts_devices = {}

for tester in payload["results"]
  for device in tester["devices"]
    tester_name = tester["name"]
    device_model = device["model"]
    device_udid = device["udid"]
    device_os = device["os"]
    
    if device_os == "1"
      puts "#{tester_name} #{device_model} - #{device_udid}"
    
      tryouts_devices[device_udid] = "#{tester_name} #{device_model}"
    end
  end
end


decoded_itunes_token = Base64.urlsafe_decode64(itunes_token)

# create the cipher for encrypting
cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
cipher.decrypt
cipher.key = Digest::SHA1.hexdigest(CYPHER_HASH)
cipher.iv = CYPHER_SALT

decrypted_token = cipher.update(decoded_itunes_token)
decrypted_token << cipher.final

credentials = decrypted_token.split("|:|")
username = credentials[0]
password = credentials[1]


puts "Logging in..."

Spaceship.login(username, password)

Spaceship::Portal.client.team_id=(team_id)

team_name = Spaceship::Portal.client.team_information["name"]

puts "Logged in to #{team_name}"

if Spaceship::Portal.client.in_house?
  profiles = Spaceship.provisioning_profile.in_house.find_by_bundle_id(bundle_id)
  profile = nil

  if profiles.length == 0
    puts "Creating profile..."

    cert = Spaceship.certificate.production.all.first
    profile = Spaceship.provisioning_profile.ad_hoc.create!(
      bundle_id: bundle_id,
      certificate: cert,
      name: "#{app_name} Enterprise"
    )
  else
    profile = profiles.first
  end

  puts "Downloading profile #{profile.uuid}..."

  File.write(provision_output_path, profile.download)
  File.write("#{provision_output_path}_uuid", profile.uuid)
else
  all_devices = Spaceship.device.all

  puts "Found #{all_devices.length} devices"

  for device in all_devices
    if tryouts_devices.keys.include?(device.udid)
      tryouts_devices.delete(device.udid)
    end
  end

  if tryouts_devices.length > 0
    puts "Found #{tryouts_devices.length} missing devices"

    tryouts_devices.each { |device_udid, device_name|
      puts "Registering #{device_udid}"

      Spaceship.device.create!(name: device_name, udid: device_udid)
    }
  end

  profiles = Spaceship.provisioning_profile.ad_hoc.find_by_bundle_id(bundle_id: bundle_id)
  profile = nil

  if profiles.length == 0
    puts "Creating profile..."

    cert = Spaceship.certificate.production.all.first
    profile = Spaceship.provisioning_profile.ad_hoc.create!(
      bundle_id: bundle_id,
      certificate: cert,
      name: profile_name
    )
  else
    puts "Updating profile..."

    for remote_profile in profiles
      if remote_profile.name == profile_name
        profile = remote_profile
      end
    end

    if profile == nil
      profile = profiles.first
    end
  
    if tryouts_devices.length > 0
      profile.devices = Spaceship::Device.all_for_profile_type(profile.type)
      profile = profile.update!
    end
  end

  puts "Downloading profile #{profile.uuid} #{profile.name}..."

  File.write(provision_output_path, profile.download)
  File.write("#{provision_output_path}_uuid", profile.uuid)
end
