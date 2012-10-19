require 'rake'
require 'appsignal/marker'
require 'appsignal/transmitter'
require 'logger'

namespace :appsignal do
  desc "Transmit the deploy marker to appsignal"
  task :notify_of_deploy do
    marker_data = {
      :revision => ENV['REVISION'],
      :repository => ENV['REPOSITORY'],
      :user => ENV['USER']
    }

    marker = Appsignal::Marker.new(
      marker_data,
      ENV['PWD'],
      ENV['RAILS_ENV'],
      Logger.new(STDOUT)
    )
    marker.transmit
  end
end
