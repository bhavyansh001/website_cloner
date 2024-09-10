require 'net/http'
require 'uri'
require 'fileutils'
require 'openssl'

module WebsiteCloner
  class Downloader
    attr_reader :output_dir, :base_url

    def initialize(base_url, output_dir)
      @base_url = URI.parse(base_url)
      @output_dir = output_dir
      FileUtils.mkdir_p(@output_dir)
      FileUtils.mkdir_p(File.join(@output_dir, 'assets'))
      FileUtils.mkdir_p(File.join(@output_dir, 'css'))
      FileUtils.mkdir_p(File.join(@output_dir, 'js'))
    end

    def download_page(url)
      Utils.logger.info "Downloading page: #{url}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request_path = uri.path.empty? ? '/' : uri.path
      request_path += "?#{uri.query}" if uri.query

      response = http.get(request_path)

      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        download_page(response['location'])
      else
        response.error!
      end
    end

    def download_asset(url, type)
      Utils.logger.info "Downloading asset: #{url}"
      uri = URI.parse(URI.join(@base_url, url))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request_path = uri.path.empty? ? '/' : uri.path
      request_path += "?#{uri.query}" if uri.query

      response = http.get(request_path)

      case response
      when Net::HTTPSuccess
        content = response.body
        filename = File.basename(uri.path).gsub(/^[0-9a-f]+_/, '')
        filename = URI.decode_www_form_component(filename).gsub('%20', '-')
        dir = case type
              when 'css' then 'css'
              when 'js' then 'js'
              else 'assets'
              end
        path = File.join(@output_dir, dir, filename)
        FileUtils.mkdir_p(File.dirname(path))

        File.open(path, 'wb') do |file|
          file.write(content)
        end

        "#{dir}/#{filename}"
      else
        Utils.logger.warn "Failed to download asset: #{url}"
        url # Return the original URL if download fails
      end
    end
  end
end
