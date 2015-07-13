class YamlDbToCloudGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/scheduler_backup.rb",
                "require 'fog_aws'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.new

scheduler.at '04:00:00' do
  FogAws.backup_dump_to_s3
end
"
  end
end
