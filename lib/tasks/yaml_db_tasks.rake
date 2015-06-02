require 'archive_zip'
require 'amazon_s3'

namespace :db do
  desc "Dump schema and data to db/schema.rb and db/data.yml"
  task(:dump => [ "db:schema:dump", "db:data:dump" ])

  desc "Load schema and data from db/schema.rb and db/data.yml"
  task(:load => [ "db:schema:load", "db:data:load" ])

  namespace :data do
    desc "Dump contents of database to dir and zip"
    task :dump_dir_zip => :environment do
      YamlDb::RakeTasks.data_dump_dir_task
      ArchiveZip.add_directory
    end

    desc "Dump contents of database to curr_dir and zip with load to s3"
    task :dump_dir_zip_s3 => :environment do
      time = Time.now.strftime('%F_%T')
      YamlDb::RakeTasks.data_dump_dir_task(time)
      ArchiveZip.add_directory(time)
      AmazonS3.load_archive_zip(time)
    end

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
    task :load_dir  => :environment do
      YamlDb::RakeTasks.data_load_dir_task
    end
  end
end
