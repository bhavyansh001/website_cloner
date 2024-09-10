# Website Cloner

Website Cloner is a Ruby tool that allows you to clone websites locally, including all assets and linked pages.

## Features

- Downloads the main page and all linked pages
- Stores images and other assets locally
- Updates references to point to local assets
- Maintains directory structure for pages
- Provides colored logging for better visibility

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/website-cloner.git
   cd website-cloner
   ```

2. Install dependencies:
   ```
   bundle install
   chmod +x bin/website-cloner
   ```

## Usage

Run the website cloner from the command line:

```
./bin/website-cloner <url> <output_directory> <max-pages>
```

For example:

```
./bin/website-cloner https://example.com output
```

This will clone the website at https://example.com and store it in the `output` directory. Note that the default number of pages scraped as coded in `bin/website-cloner` is 20.

## Project Structure

```
website-cloner/
├── bin/
│   └── website-cloner
├── lib/
│   ├── website_cloner/
│   │   ├── downloader.rb
│   │   ├── parser.rb
│   │   └── utils.rb
│   └── website_cloner.rb
├── Gemfile
└── README.md
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.