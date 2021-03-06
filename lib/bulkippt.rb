require "bulkippt/version"
require "bulkippt/fake_service"

require 'csv'
require 'logger'

module Bulkippt

  class Loader

    attr_reader :service, :logger

    def initialize(service, logger = Logger.new(STDOUT))
      @service = service
      @logger = logger
    end

    def credentials_valid?
      begin
        @account = @service.account
        true
      rescue Kippt::APIError => e
        false
      rescue => e
        @logger.error e.message
        false
      end
    end

    def extract_bookmarks(file_path)
      begin
        validate_file_path file_path
      rescue => e
        @logger.error e.message
        return []
      end

      begin
        @csv = CSV.read(file_path, {headers: true})
      rescue ArgumentError => e
        @logger.warn e.message + " | Forcing UTF-8..."
        begin
          data = IO.read(file_path).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
          @csv = CSV.parse(data, {headers: true})
        rescue => e
          @logger.error "Failed to force UTF-8 | " + e.message
          return []
        end
      end

      begin
        validate_headers(normalize_headers(@csv.headers))
        parse_csv(@csv)
      rescue => e
        @logger.error e.message
        []
      end
    end

    def submit_bookmarks(bookmarks)
      begin
        submitted = []
        bookmarks.each do |bookmark|
          clip = clip_from_bookmark bookmark
          if clip.save
            submitted << clip
            @logger.info "SUCCESS: #{clip.title} #{clip.url}"
          else
            @logger.error "FAILURE: #{clip.title} #{clip.url} | #{clip.errors[]}"
          end
        end
        submitted
      rescue => e
        @logger.error e.message
        []
      end
    end

    private

    def parse_csv(csv)
      result = []
      csv.each do |b|
        row = {}
        b.to_hash.each_pair {|k,v| row.merge!({k.downcase => v})}
        result << bookmark_instance(row['url'], row['title'], row.fetch('description',''), row.fetch('folder',''))
      end
      result
    end

    def parse_file(file_path)
      IO.read(file_path).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
    end

    def normalize_headers(headers)
      headers.map(&:downcase)
    end

    def validate_file_path(file_path)
      raise "File not found: #{file_path}" if !File.exists?(file_path)
    end

    def validate_headers(headers)
      #url and title are required, description and folder are not
      raise "Missing 'url' column" unless headers.include? 'url'
      raise "Missing 'title' column" unless headers.include? 'title'
    end

    def bookmark_instance(url, title, desc, folder)
      OpenStruct.new(url: url, title: title, description: desc, folder: folder)
    end

    def clip_from_bookmark(bookmark)
      clip = @service.clips.build
      clip.url = bookmark.url
      clip.title = bookmark.title
      clip.notes = bookmark.description
      clip
    end

  end
end
