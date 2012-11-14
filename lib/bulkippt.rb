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
        @csv = CSV.read(file_path, {headers: true})
        validate_headers(normalize_headers(@csv.headers))
        parse_csv(@csv)
      rescue => e
        @logger.error e.message
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

    def normalize_headers(headers)
      headers.map(&:downcase)
    end

    def validate_file_path(file_path)
      raise Exception, "CSV not found: #{file_path}" if !File.exists?(file_path)
    end

    def validate_headers(headers)
      #url and title are required, description and folder are not
      raise Exception, "Missing 'url' column" unless headers.include? 'url'
      raise Exception, "Missing 'title' column" unless headers.include? 'title'
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
