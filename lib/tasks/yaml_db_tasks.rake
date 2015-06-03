require 'archive_zip'
require 'amazon_s3'

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
    desc "Dump contents of database to dir and zip"
    task :dump_dir_zip => :environment do
      file_name = Time.now.strftime('%F_%T')
      YamlDb::RakeTasks.data_dump_dir_task_zip(file_name)
      ArchiveZip.add_to_zip(file_name)
    end

    desc "Dump contents of database to dir and zip with load to s3"
    task :dump_dir_zip_to_s3 => :environment do
      file_name = Time.now.strftime('%F_%T')
      YamlDb::RakeTasks.data_dump_dir_task_zip(file_name)
      ArchiveZip.add_to_zip(file_name)
      AmazonS3.backup_zip(file_name)
    end

    desc "Dump zip to s3"
    task :dump_zip_to_s3, [:file_name] => :environment do |t, args|
      file_name = args.file_name
      AmazonS3.backup_zip(file_name)
    end

    # Restore backup: Archive Zip and Amazon S3
    desc "Load zip from s3"
    task :load_zip_from_s3, [:file_name] => :environment do |t, args|
      file_name = args.file_name
      AmazonS3.restore_zip(file_name)
    end

    desc "Load zip from s3 to dir"
    task :load_zip_from_s3_to_dir, [:file_name] => :environment do |t, args|
      file_name = args.file_name
      AmazonS3.restore_zip(file_name)
      ArchiveZip.restore_from_zip(file_name)
    end

    desc "Load zip from s3 to dir and db"
    task :load_zip_from_s3_to_dir_and_db, [:file_name] => :environment do |t, args|
      file_name = args.file_name
      AmazonS3.restore_zip(file_name)
      ArchiveZip.restore_from_zip(file_name)
      YamlDb::RakeTasks.data_load_dir_task_zip(file_name)
    end

    desc "Load zip to dir and db"
    task :load_zip_to_dir_and_db, [:file_name] => :environment do |t, args|
      file_name = args.file_name
      ArchiveZip.restore_from_zip(file_name)
      YamlDb::RakeTasks.data_load_dir_task_zip(file_name)
    end

    desc "Load dir to db"
    task :load_dir_to_db, [:file_name] => :environment do |t, args|
      file_name = args.file_name
      ArchiveZip.restore_from_zip(file_name)
      YamlDb::RakeTasks.data_load_dir_task_zip(file_name)
    end
  end
end
