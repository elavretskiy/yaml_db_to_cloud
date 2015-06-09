require 'archive/zip'

class ArchiveZip
  class << self
    def add_to_zip(file_name)
      Archive::Zip.archive(dump_dir("/#{file_name}.zip"),
                           dump_dir("/#{file_name}"))
    end

    def restore_from_zip(file_name)
      Archive::Zip.extract(dump_dir("/#{file_name}.zip"),
                           dump_dir('/'))
    end

    def remove_zip(file_name)
      FileUtils.rm(dump_dir("/#{file_name}.zip"))
    end

    def remove_folder(file_name)
      FileUtils.rm_rf(dump_dir("/#{file_name}"))
    end

    private

    def dump_dir(dir = '')
      "#{Rails.root}/db#{dir}"
    end
  end
end
