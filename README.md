# NetSearch Blacklight

A simple Blacklight interface for the Full Text Search for the danish webarchive: [Netarkivet.dk](http://netarkivet.dk)

Requires a setup where the harvested webpages are indexed in SOLR and with a Wayback for dissemination.

For more on these see:
- [Blacklight](http://projectblacklight.org/)
- [SOLR](http://lucene.apache.org/solr/)
- [Wayback](https://archive.org/web/)


## Prerequisites
Needs Ruby 1.9 or newer, Rails 4 (or 3.2) and sqlite3 with development headers installed as necessary. Also needs a javascript interpreter supported by Ruby - nodejs should do fine.

### Fedora
To install these on Fedora do the following

`yum install ruby ruby-devel rubygem-rails sqlite sqlite-devel nodejs`

### Ubuntu
To install these on Ubuntu do the following

`sudo apt-get install ruby-dev ruby-rails-4.0 libsqlite3-dev sqlite`

Then install nodejs for Ruby

`bundler nodejs`

Since Ubuntu currently has Ruby 1.9.1 also install `rdoc-data`

```
sudo gem install rdoc-data
sudo rdoc-data --install
```

If it still does not work then try the following

`sudo gem install rails`

## Setup
```
cd search_app
bundle install
rake db:migrate
```

That should install all the needed parts for Blacklight and setup its database.

Now to run the server do `rails server` and open [http://localhost:3000/](http://localhost:3000/)

## Configuration
The following documents should be edited 

- `config/solr.yml` to point to your Netarchive Solr instance.
- `config/wayback.yml` to point to your Wayback machine, and define the URL/date format.

