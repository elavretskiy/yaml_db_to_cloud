require 'archive_zip'
require 'fog/aws'

class FogAws
  class << self
    def backup_dump_to_s3
      db_name = get_db_name
      file_name = "#{Time.zone.now.strftime('%F_%T')}"
      puts file_name

      puts 'Получение файлов резервной копии из БД'
      YamlDb::RakeTasks.data_dump_dir_for_zip(file_name)

      puts 'Архивирование файлов резервной копии'
      ArchiveZip.add_to_zip(file_name)

      puts 'Отправка резервной копии в хранилище'
      backup_zip_to_s3(db_name, file_name)

      puts 'Удаление временных файлов'
      ArchiveZip.remove_zip(file_name)
      ArchiveZip.remove_folder(file_name)
    end

    def restore_dump_by_name_from_s3(file_name)
      db_name = get_db_name
      puts file_name

      puts 'Получение резервной копии из хранилища'
      restore_zip_from_s3(db_name, file_name)

      puts 'Разархивирование резервной копии'
      ArchiveZip.restore_from_zip(file_name)

      puts 'Отправка файлов резервной копии в БД'
      YamlDb::RakeTasks.data_load_dir_for_zip(file_name)

      puts 'Удаление временных файлов'
      ArchiveZip.remove_zip(file_name)
      ArchiveZip.remove_folder(file_name)
    end

    def restore_last_dump_from_s3
      db_name = get_db_name
      file_name = get_name_of_last_file(db_name)

      if file_name
        restore_dump_by_name_from_s3(file_name)
      end
    end

    def backup_zip_to_s3(db_name, file_name)
      connection = connection_to_aws
      directory = connection.directories.get(db_name)

      unless directory
        directory = connection.directories.create(
          key:    db_name,
          public: false
        )
      end

      p connection.directories

      s3_file = directory.files.create(
        key:    "#{file_name}.zip",
        body:   File.open(dump_dir("/#{file_name}.zip")),
        public: false
      )
      s3_file.save
    end

    def restore_zip_from_s3(db_name, file_name)
      connection = connection_to_aws
      directory = connection.directories.get(db_name)

      if directory
        s3_file = directory.files.get("#{file_name}.zip")

        if s3_file
          local_file = File.open(dump_dir("/#{file_name}.zip"), 'w:ASCII-8BIT')
          local_file.write(s3_file.body)
          local_file.close
        else
          puts "Каталог #{db_name} не содержит файл #{file_name}.zip"
        end
      else
        puts "Каталог #{db_name} не существует"
      end
    end

    private

    def connection_to_aws
      Fog::Storage.new({
                         provider:                 'AWS',
                         aws_access_key_id:        ENV['ACCESS_KEY_ID'],
                         aws_secret_access_key:    ENV['SECRET_ACCESS_KEY'],
                         region:                   ENV['AWS_REGION']
                       })
    end

    def get_name_of_last_file(db_name)
      connection = connection_to_aws
      directory = connection.directories.get(db_name)

      if directory
        files = directory.files

        if files.any?
          last_file_index = files.size - 1
          files[last_file_index].key.delete!('.zip')
        else
          puts "Каталог #{db_name} не содержит резервных копий БД"
        end
      else
        puts "Каталог #{db_name} не существует"
      end
    end

    def dump_dir(dir = '')
      "#{Rails.root}/db#{dir}"
    end

    def get_db_name
      config = Rails.configuration.database_configuration
      db_name = config[Rails.env]['database']
      db_name.delete! '_'
    end
  end
end
