require 'fileutils'
require 'json'
require 'time'

module ZohomailClient
  class Cache
    def initialize(cache_file_path)
      @cache_file_path = cache_file_path
    end

    def get_folder_id(folder_name)
      cache = read_cache
      return nil unless cache

      folders = cache.dig("folders") || []
      cached_entry = folders.find { |f| f["name"].downcase == folder_name.downcase }

      if cached_entry
        created_at = Time.parse(cached_entry["created_at"])
        # Invalidate cache if older than 1 week
        if (Time.now - created_at) < 7 * 24 * 60 * 60
          return cached_entry["id"]
        end
      end
      nil
    end

    def update_folders(folder_data)
      cache = read_cache || {}
      cache["folders"] = folder_data.map do |folder|
        {
          "name" => folder["folderName"],
          "id" => folder["folderId"],
          "created_at" => Time.now.iso8601
        }
      end
      write_cache(cache)
    end

    private

    def read_cache
      return nil unless @cache_file_path && File.exist?(@cache_file_path)
      JSON.parse(File.read(@cache_file_path))
    rescue JSON::ParserError
      {} # Return empty hash if cache file is corrupt
    end

    def write_cache(data)
      return unless @cache_file_path
      FileUtils.mkdir_p(File.dirname(@cache_file_path))
      File.write(@cache_file_path, JSON.pretty_generate(data))
    end
  end
end
