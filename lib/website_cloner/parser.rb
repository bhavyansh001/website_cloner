require 'nokogiri'
require 'uri'

module WebsiteCloner
  class Parser
    def initialize(downloader)
      @downloader = downloader
      @file_mapping = {}
    end

    def parse_and_download(content, url)
      doc = Nokogiri::HTML(content)
      base_uri = URI.parse(url)

      # Ensure the path is valid and not empty
      path = base_uri.path.empty? || base_uri.path == '/' ? '/index.html' : base_uri.path

      # Calculate the depth of the directory structure
      depth = [path.count('/') - 1, 0].max
      prefix = '../' * depth

      new_pages = []

      # Download and update image sources
      doc.css('img').each do |img|
        src = img['src']
        next if src.nil? || src.empty?
        new_src = @downloader.download_asset(src, 'image')
        img['src'] = prefix + new_src # Add the correct prefix for assets in subdirs
        @file_mapping[src] = new_src

        # Remove srcset attribute to prevent loading from CDN
        img.remove_attribute('srcset')
        img.remove_attribute('imagesrcset')

        # Update sizes attribute if present
        img['sizes'] = '100vw' if img['sizes']
      end

      # Download and update stylesheet links
      doc.css('link[rel="stylesheet"]').each do |link|
        href = link['href']
        next if href.nil? || href.empty?
        new_href = @downloader.download_asset(href, 'css')
        link['href'] = prefix + new_href # Add the correct prefix for assets in subdirs
        @file_mapping[href] = new_href
      end

      # Download and update script sources
      doc.css('script').each do |script|
        src = script['src']
        next if src.nil? || src.empty?
        new_src = @downloader.download_asset(src, 'js')
        script['src'] = prefix + new_src # Add the correct prefix for assets in subdirs
        @file_mapping[src] = new_src
      end

      # Handle internal links starting with '/'
      doc.css('a').each do |a|
        href = a['href']
        next if href.nil? || href.empty?

        # Target only internal links that start with '/'
        if href.start_with?('/')
          # Add the new URL to new_pages for downloading before modification
          new_pages << URI.join(base_uri, href).to_s

          # Special handling for homepage
          if href == '/'
            a['href'] = prefix + 'index.html'
          else
            # Remove leading '/' for saving the local file
            href.sub!(/^\//, '')

            # Append '.html' if it's missing and not a file download (like .pdf)
            href += '.html' unless href =~ /\.\w+$/

            # Update the href attribute
            a['href'] = href
          end
        end
      end

      # Save the updated HTML
      save_html(doc.to_html, url)

      new_pages
    end

    def organize_files
      Dir.glob(File.join(@downloader.output_dir, '**', '*')).each do |file|
        next if File.directory?(file)

        relative_path = file.sub(@downloader.output_dir + '/', '')
        dirname = File.dirname(relative_path)
        basename = File.basename(relative_path)

        if dirname.match?(/^[0-9a-f]+$/)
          new_basename = URI.decode_www_form_component(basename).gsub('%20', '-')
          new_path = case
                     when new_basename.end_with?('.css')
                       File.join(@downloader.output_dir, 'css', new_basename.gsub(/^[0-9a-f]+_/, ''))
                     when new_basename.end_with?('.js')
                       File.join(@downloader.output_dir, 'js', new_basename.gsub(/^[0-9a-f]+_/, ''))
                     else
                       File.join(@downloader.output_dir, 'assets', new_basename.gsub(/^[0-9a-f]+_/, ''))
                     end

          FileUtils.mv(file, new_path)
          @file_mapping["/#{relative_path}"] = "#{new_path.sub(@downloader.output_dir + '/', '')}"
        elsif !basename.include?('.') && !dirname.start_with?('css', 'js', 'assets')
          # This is likely a subpage without an extension
          new_path = "#{file}.html"
          FileUtils.mv(file, new_path)
          @file_mapping["/#{relative_path}"] = "#{new_path.sub(@downloader.output_dir + '/', '')}"
        end
      end

      update_references
    end

    private

    def save_html(content, url)
      uri = URI.parse(url)
      path = uri.path.empty? || uri.path == '/' ? '/index.html' : uri.path
      path += '.html' unless path.end_with?('.html')
      full_path = File.join(@downloader.output_dir, path)
      FileUtils.mkdir_p(File.dirname(full_path))

      File.open(full_path, 'w') do |file|
        file.write(content)
      end
    end

    def update_references
      Dir.glob(File.join(@downloader.output_dir, '**', '*.html')).each do |html_file|
        content = File.read(html_file)
        @file_mapping.each do |old_path, new_path|
          content.gsub!(old_path, new_path)
          content.gsub!("//#{new_path}", new_path) # Remove any double slashes
        end
        File.write(html_file, content)
      end
    end
  end
end
