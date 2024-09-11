require 'spec_helper'
require 'website_cloner/parser'
require 'website_cloner/downloader'

RSpec.describe WebsiteCloner::Parser do
  let(:base_url) { 'http://example.com' }
  let(:output_dir) { 'tmp/test_output' }
  let(:downloader) { instance_double(WebsiteCloner::Downloader) }
  let(:parser) { described_class.new(downloader) }

  before do
    allow(downloader).to receive(:output_dir).and_return(output_dir)
    FileUtils.mkdir_p(output_dir)
  end

  after do
    FileUtils.rm_rf(output_dir)
  end

  describe '#parse_and_download' do
    let(:content) do
      <<-HTML
        <html>
          <head>
            <link rel="stylesheet" href="/styles.css">
            <script src="/script.js"></script>
          </head>
          <body>
            <img src="/image.jpg" srcset="/image2x.jpg 2x" sizes="(max-width: 600px) 100vw, 50vw">
            <a href="/">Home</a>
            <a href="/about">About</a>
          </body>
        </html>
      HTML
    end

    before do
      allow(downloader).to receive(:download_asset).and_return('downloaded_file')
    end

    it 'downloads and updates asset sources' do
      new_pages = parser.parse_and_download(content, base_url)

      expect(downloader).to have_received(:download_asset).with('/styles.css', 'css')
      expect(downloader).to have_received(:download_asset).with('/script.js', 'js')
      expect(downloader).to have_received(:download_asset).with('/image.jpg', 'image')

      expect(new_pages).to include('http://example.com/about')
    end

    it 'removes srcset and updates sizes attributes on images' do
      parser.parse_and_download(content, base_url)

      parsed_content = File.read(File.join(output_dir, 'index.html'))
      expect(parsed_content).to include('src="downloaded_file"')
      expect(parsed_content).not_to include('srcset')
      expect(parsed_content).to include('sizes="100vw"')
    end

    it 'updates internal links' do
      parser.parse_and_download(content, base_url)

      parsed_content = File.read(File.join(output_dir, 'index.html'))
      expect(parsed_content).to include('href="index.html"')
      expect(parsed_content).to include('href="about.html"')
    end
  end

  describe '#organize_files' do
    before do
      FileUtils.mkdir_p(File.join(output_dir, '1a2b3c'))
      FileUtils.mkdir_p(File.join(output_dir, 'css'))
      File.write(File.join(output_dir, '1a2b3c', '4d5e6f_style.css'), 'body { color: red; }')
      File.write(File.join(output_dir, 'subpage'), 'Subpage content')
    end

    it 'organizes files into appropriate directories' do
      parser.organize_files

      expect(File.exist?(File.join(output_dir, 'css', 'style.css'))).to be true
      expect(File.exist?(File.join(output_dir, 'subpage.html'))).to be true
    end
  end
end
