require_relative 'website_cloner/downloader'
require_relative 'website_cloner/parser'
require_relative 'website_cloner/utils'
require 'set'

module WebsiteCloner
  class Error < StandardError; end

  def self.clone(url, output_dir, max_pages: 100, session_cookie: nil)
    Utils.logger.info "Starting to clone #{url}"
    downloader = Downloader.new(url, output_dir, session_cookie)
    parser = Parser.new(downloader)

    visited_pages = Set.new
    pages_to_visit = [url]

    while !pages_to_visit.empty? && visited_pages.size < max_pages
      current_url = pages_to_visit.shift
      next if visited_pages.include?(current_url)

      visited_pages.add(current_url)
      Utils.logger.info "Processing page #{visited_pages.size}/#{max_pages}: #{current_url}"

      begin
        content = downloader.download_page(current_url)
        new_pages = parser.parse_and_download(content, current_url)
        pages_to_visit.concat(new_pages - visited_pages.to_a)
      rescue => e
        Utils.logger.error "Error processing #{current_url}: #{e.message}"
      end
    end

    Utils.logger.info "Finished cloning. Processed #{visited_pages.size} pages."
    Utils.logger.info "Organizing files and updating references..."
    parser.organize_files
    Utils.logger.info "Done organizing files and updating references."
  end
end
