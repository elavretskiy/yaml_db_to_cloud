require 'fog_aws'
require 'rufus/scheduler'

namespace :db do
  desc "Dump schema and data to db/schema.rb and db/data.yml"
  task(:dump => [ "db:schema:dump", "db:data:dump" ])

  desc "Load schema and data from db/schema.rb and db/data.yml"
  task(:load => [ "db:schema:load", "db:data:load" ])

  namespace :data do
    desc "Dump contents of database to db/data.extension (defaults to yaml)"
    task :dump => :environment do
      YamlDb::RakeTasks.data_dump_task
    end

    desc "Dump contents of database to curr_dir_name/tablename.extension (defaults to yaml)"
    task :dump_dir => :environment do
      YamlDb::RakeTasks.data_dump_dir_task
    end

    desc "Load contents of db/data.extension (defaults to yaml) into database"
    task :load => :environment do
      YamlDb::RakeTasks.data_load_task
    end

    desc "Load contents of db/data_dir into database"
    task :load_dir => :environment do
      YamlDb::RakeTasks.data_load_dir_task
    end

    # Create backup: Archive Zip and Amazon S3
    desc "Dump contents of database to dir and zip with load to s3"
    task :dump_backup_zip_to_s3 => :environment do
      FogAws.backup_dump_to_s3
    end

    # Restore backup: Archive Zip and Amazon S3
    desc "Restore backup zip from s3 to db by name"
    task :dump_restore_zip_from_s3_by_name, [:file_name] => :environment do |t, args|
      FogAws.restore_dump_by_name_from_s3(args.file_name)
    end

    desc "Restore last backup zip from s3 to db"
    task :dump_restore_last_zip_from_s3 => :environment do
      FogAws.restore_last_dump_from_s3
    end

    # Rufus Scheduler Backup
    desc "Rufus Scheduler Backup"
    task :dump_scheduler_backup => :environment do
      scheduler = Rufus::Scheduler.new

      scheduler.at '04:00:00' do
        FogAws.backup_dump_to_s3
      end

      scheduler.join
    end
  end
end
