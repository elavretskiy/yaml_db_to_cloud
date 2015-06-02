class AmazonS3
    def self.load_archive_zip(time)
      connection = Fog::Storage.new({
                                      :provider                 => 'AWS',
                                      :aws_access_key_id        => ENV['ACCESS_KEY_ID'],
                                      :aws_secret_access_key    => ENV['SECRET_ACCESS_KEY']
                                    })

      directory = connection.directories.get(ENV['BUCKET_NAME'])

      unless directory
        directory = connection.directories.create(
          key:    ENV['BUCKET_NAME'],
          public: false
        )
      end

      p connection.directories

      file = directory.files.create(
        key:    time,
        body:   File.open("#{Rails.root}/db/#{time}.zip"),
        public:  false
      )
      file.save
    end
end
