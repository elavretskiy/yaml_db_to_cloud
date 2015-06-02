require 'archive/zip'

class ArchiveZip
  class << self
    def add_directory
      time = Time.now.strftime('%F_%T')
      Archive::Zip.archive("#{Rails.root}/db/#{time}.zip", "#{Rails.root}/db/#{time}")
    end
  end
end
