class ArchiveZip
    def self.add_directory(time)
      Archive::Zip.archive("#{Rails.root}/db/#{time}.zip", "#{Rails.root}/db/#{time}")
    end
end
