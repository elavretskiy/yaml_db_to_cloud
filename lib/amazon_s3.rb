class AmazonS3
  class << self
    def backup_zip(file_name)
      connection = amazon_s3_connection
      directory = connection.directories.get(ENV['BUCKET_NAME'])

      unless directory
        directory = connection.directories.create(
          key:    ENV['BUCKET_NAME'],
          public: false
        )
      end

      p connection.directories

      s3_file = directory.files.create(
        key:    "#{file_name}.zip",
        body:   File.open(dump_dir("/backups/#{file_name}.zip")),
        public: false
      )
      s3_file.save
    end

    def restore_zip(file_name)
      connection = amazon_s3_connection

      directory = connection.directories.get(ENV['BUCKET_NAME'])

      if directory
        local_file = File.open(dump_dir("/restores/#{file_name}.zip"), 'w:ASCII-8BIT')
        s3_file = directory.files.get("#{file_name}.zip")
        local_file.write(s3_file.body)
        local_file.close
      end
    end

    private

    def amazon_s3_connection
      Fog::Storage.new({
                         :provider                 => 'AWS',
                         :aws_access_key_id        => ENV['ACCESS_KEY_ID'],
                         :aws_secret_access_key    => ENV['SECRET_ACCESS_KEY']
                       })
    end

    private

    def dump_dir(dir = '')
      "#{Rails.root}/db#{dir}"
    end
  end
end
