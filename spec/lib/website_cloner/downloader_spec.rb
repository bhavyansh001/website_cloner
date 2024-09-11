require 'spec_helper'
require 'website_cloner/downloader'

RSpec.describe WebsiteCloner::Downloader do
  let(:base_url) { 'http://example.com' }
  let(:output_dir) { 'tmp/test_output' }
  let(:downloader) { described_class.new(base_url, output_dir) }

  after do
    FileUtils.rm_rf(output_dir)
  end

  describe '#download_page' do
    let(:page_url) { 'http://example.com/page' }
    let(:page_content) { '<html><body>Test Page</body></html>' }

    before do
      stub_request(:get, page_url).to_return(body: page_content)
    end

    it 'downloads the page content' do
      expect(downloader.download_page(page_url)).to eq page_content
    end

    context 'when the page redirects' do
      let(:redirect_url) { 'http://example.com/new-page' }

      before do
        stub_request(:get, page_url).to_return(status: 302, headers: { 'Location' => redirect_url })
        stub_request(:get, redirect_url).to_return(body: page_content)
      end

      it 'follows the redirect and downloads the page content' do
        expect(downloader.download_page(page_url)).to eq page_content
      end
    end

    context 'when the page request fails' do
      before do
        stub_request(:get, page_url).to_return(status: 404)
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
      stub_request(:get, "#{base_url}#{asset_url}").to_return(body: asset_content)
    end

    it 'downloads and saves the asset' do
      result = downloader.download_asset(asset_url, 'image')
      expect(result).to eq 'assets/image.jpg'
      expect(File.exist?(File.join(output_dir, 'assets', 'image.jpg'))).to be true
      expect(File.read(File.join(output_dir, 'assets', 'image.jpg'))).to eq asset_content
    end

    context 'when the asset download fails' do
      before do
        stub_request(:get, "#{base_url}#{asset_url}").to_return(status: 404)
      end

      it 'returns the original URL' do
        result = downloader.download_asset(asset_url, 'image')
        expect(result).to eq asset_url
      end
    end
  end
end
