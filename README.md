# Website Cloner

Website Cloner is a Ruby gem that allows you to create local copies of websites, including all assets and linked pages. It's designed to be easy to use while providing powerful features for customization.

## Features

* Downloads the main page and all linked pages up to a specified limit
* Stores images, CSS, JavaScript, and other assets locally
* Updates references to point to local assets
* Maintains directory structure for pages
* Provides colored logging for better visibility
* Supports authenticated access through session cookies
* Handles relative and absolute URLs correctly
* Organizes downloaded files into appropriate directories (css, js, assets)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'website_cloner'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install website_cloner
```
Dependencies: nokogiri v1.15, httparty v0.21, openssl v3.0

## Usage

### Command Line Interface

The Website Cloner can be used from the command line:

```bash
website-cloner https://example.com output_dir -m 10 -s "user_session=endoded_cookie_string"
```
This example will clone https://example.com, download up to 10 pages, and store the result in the ./output_dir directory.

Options:
- `-m, --max-pages PAGES`: Maximum number of pages to clone (default: 20)
- `-s, --session-cookie COOKIE`: Session cookie for authenticated access
- `-h, --help`: Prints help information

### In Ruby Scripts

You can also use Website Cloner in your Ruby scripts:

```ruby
require 'website_cloner'

url = "https://example.com"
output_dir = "./cloned_site"
options: {
   max_pages: 50,
   session_cookie: "session_id=abc123; user_token=xyz789"
}

WebsiteCloner.clone(url, output_dir, **options)
```

## Configuration

Website Cloner uses sensible defaults, but you can configure it to suit your needs:

- `max_pages`: Controls the maximum number of pages to clone (default: 20)
- `session_cookie`: Allows authenticated access to websites that require login

## Logging

Website Cloner provides colored logging for better visibility. Log messages are output to the console and include information about the cloning process, any errors encountered, and the final status of the operation.

## Best Practices

1. Always respect the website's `robots.txt` file and terms of service.
2. Be mindful of the load you're putting on the target server. Consider adding delays between requests for busy sites.
3. When using session cookies, ensure you have permission to access and clone the authenticated content.
4. Be cautious with cloned data, especially if it contains sensitive information from authenticated pages.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bhavyansh001/website_cloner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://contributor-covenant.org) code of conduct.

## License

Website Cloner is released under the MIT License.
