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
        raise Exception, "CSV not found: #{file_path}" if !File.exists?(file_path)

        @csv = CSV.read(file_path, {headers: true})
        headers = @csv.headers.map(&:downcase) #normalize colum titles

        #url and title are required, description and folder are not
        raise Exception, "Missing 'url' column" unless headers.include? 'url'
        raise Exception, "Missing 'title' column" unless headers.include? 'title'

        bookmarks = []
        @csv.each do |b|
          row = {}
          b.to_hash.each_pair do |k,v|
            row.merge!({k.downcase => v}) 
          end
          bookmark = OpenStruct.new(url: row['url'], title: row['title'])
          bookmark.description = row['description'] if headers.include? 'description'
          bookmark.folder = row['folder'] if headers.include? 'folder'
          bookmarks << bookmark
        end
        bookmarks
      rescue => e
        @logger.error e.message
      end
    end

    def submit_bookmarks(bookmarks)
      submitted = []
      begin
        bookmarks.each do |bookmark|
          clip = @service.clips.build
          clip.url = bookmark.url
          clip.title = bookmark.title
          clip.notes = bookmark.description
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

  end
end
