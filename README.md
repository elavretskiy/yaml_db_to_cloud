# YamlDbToCloud (Amazon S3)

YamlDb is a database-independent format for dumping and restoring data.
It complements the database-independent schema format found in db/schema.rb.
The data is saved into db/data.yml.

This can be used as a replacement for mysqldump or pg_dump, but only for the
databases typically used by Rails apps. Users, permissions, schemas, triggers,
and other advanced database features are not supported - by design.

Any database that has an ActiveRecord adapter should work.

This gem supports Rails 3.x and 4.x.

## Installation

Simply add to your Gemfile:

    gem 'yaml_db', git: 'https://github.com/itbeaver/yaml_db_to_cloud.git'

All rake tasks will then be available to you.

## Usage

    rake db:data:dump_backup_zip_to_s3   ->   Backup database to Amazon S3
    rake db:data:dump_restore_last_zip_from_s3   ->   Restore database from Amazon S3

## Config

    Amazon S3 init, add to file .env:
        ACCESS_KEY_ID='value'
        SECRET_ACCESS_KEY='value'
        AWS_REGION='value'

    Rufus init for every day backups, create file in config/initializers:
        require 'fog_aws'
        require 'rufus/scheduler'

        scheduler = Rufus::Scheduler.new
        scheduler.at '04:00:00' do
          FogAws.backup_dump_to_s3
        end
