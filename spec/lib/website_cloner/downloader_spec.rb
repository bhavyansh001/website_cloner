require 'spec_helper'
require 'website_cloner/downloader'

RSpec.describe WebsiteCloner::Downloader do
  let(:base_url) { 'http://example.com' }
  let(:output_dir) { 'tmp/test_output' }
  let(:session_cookie) { 'session=abc123' }
  let(:downloader) { described_class.new(base_url, output_dir, session_cookie) }

  after do
    FileUtils.rm_rf(output_dir)
  end

  describe '#download_page' do
    let(:page_url) { 'http://example.com/page' }
    let(:page_content) { '<html><body>Test Page</body></html>' }

    before do
      stub_request(:get, page_url)
        .with(headers: { 'Cookie' => session_cookie })
        .to_return(body: page_content)
    end

    it 'downloads the page content' do
      expect(downloader.download_page(page_url)).to eq page_content
    end

    context 'when the page redirects' do
      let(:redirect_url) { 'http://example.com/new-page' }

      before do
        stub_request(:get, page_url)
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(status: 302, headers: { 'Location' => redirect_url })
        stub_request(:get, redirect_url)
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(body: page_content)
      end

      it 'follows the redirect and downloads the page content' do
        expect(downloader.download_page(page_url)).to eq page_content
      end
    end

    context 'when the page request fails' do
      before do
        stub_request(:get, page_url)
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(status: 404)
      end

      it 'raises an error' do
        expect { downloader.download_page(page_url) }.to raise_error(Net::HTTPServerException)
      end
    end
  end

  describe '#download_asset' do
    let(:asset_url) { '/assets/image.jpg' }
    let(:asset_content) { 'fake image content' }

    before do
      stub_request(:get, "#{base_url}#{asset_url}")
        .with(headers: { 'Cookie' => session_cookie })
        .to_return(body: asset_content)
    end

    it 'downloads and saves the asset' do
      result = downloader.download_asset(asset_url, 'image')
      expect(result).to eq 'assets/image.jpg'
      expect(File.exist?(File.join(output_dir, 'assets', 'image.jpg'))).to be true
      expect(File.read(File.join(output_dir, 'assets', 'image.jpg'))).to eq asset_content
    end

    context 'when downloading a CSS asset' do
      let(:css_url) { '/styles/main.css' }
      let(:css_content) { 'body { color: red; }' }

      before do
        stub_request(:get, "#{base_url}#{css_url}")
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(body: css_content)
      end

      it 'saves the CSS file in the css directory' do
        result = downloader.download_asset(css_url, 'css')
        expect(result).to eq 'css/main.css'
        expect(File.exist?(File.join(output_dir, 'css', 'main.css'))).to be true
        expect(File.read(File.join(output_dir, 'css', 'main.css'))).to eq css_content
      end
    end

    context 'when downloading a JS asset' do
      let(:js_url) { '/scripts/app.js' }
      let(:js_content) { 'console.log("Hello");' }

      before do
        stub_request(:get, "#{base_url}#{js_url}")
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(body: js_content)
      end

      it 'saves the JS file in the js directory' do
        result = downloader.download_asset(js_url, 'js')
        expect(result).to eq 'js/app.js'
        expect(File.exist?(File.join(output_dir, 'js', 'app.js'))).to be true
        expect(File.read(File.join(output_dir, 'js', 'app.js'))).to eq js_content
      end
    end

    context 'when the asset has a complex filename' do
      let(:complex_url) { '/assets/complex%20file_name-123.jpg' }
      let(:complex_content) { 'complex file content' }

      before do
        stub_request(:get, "#{base_url}#{complex_url}")
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(body: complex_content)
      end

      it 'sanitizes the filename' do
        result = downloader.download_asset(complex_url, 'image')
        expect(result).to eq 'assets/complex file_name-123.jpg'
      end
    end

    context 'when the asset download fails' do
      before do
        stub_request(:get, "#{base_url}#{asset_url}")
          .with(headers: { 'Cookie' => session_cookie })
          .to_return(status: 404)
      end

      it 'returns the original URL' do
        result = downloader.download_asset(asset_url, 'image')
        expect(result).to eq asset_url
      end
    end
  end
end
