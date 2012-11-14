# Bulkippt

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jboursiquot/bulkippt)

Allows you to upload your bookmarks to kippt.com in bulk. You'll need a kippt.com account (of course) from which you'll obtain your API token along with your username. From there, all you need is a CSV file with url, title and description headers and the loader will push those links to kippt.com on your behalf.

## Installation

Add this line to your application's Gemfile:

    gem 'bulkippt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bulkippt

## Usage
```ruby
require 'kippt'
require 'bulkippt'
require 'yaml' # if you store your creds in a yaml file

creds = YAML.load(File.open(File.expand_path('./config/my_kippt_creds.yml')))
service = Kippt::Client.new(username: creds['username'], token: creds['token'])
loader = Bulkippt::Loader.new(client, Logger.new(STDOUT))
csv_path = File.expand_path('./my_bookmarks.csv')
bookmarks = loader.extract_bookmarks csv_path
submitted = loader.submit_bookmarks bookmarks
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
