class ArchiveZip
  class << self
    def add_to_zip(file_name)
      Archive::Zip.archive(dump_dir("/backups/#{file_name}.zip"),
                           dump_dir("/backups/#{file_name}"))
    end

    def restore_from_zip(file_name)
      Archive::Zip.extract(dump_dir("/restores/#{file_name}.zip"),
                           dump_dir('/restores/'))
    end

    private

    def dump_dir(dir = '')
      "#{Rails.root}/db#{dir}"
    end
  end
end
