require 'rest-client'
require 'fileutils'
require 'json'

module RubyChopped
  extend self

  def create(opts={})
    folder = opts[:name]
    if File.exist?(folder)
      unless opts[:force]
        puts "#{folder} already exists, use -f/--force option to recreate it"
        exit 1
      end
    end

    puts "Creating #{folder} basket..."
    FileUtils.mkdir_p("#{folder}/lib")

    File.open("#{folder}/lib/#{folder}.rb", "w") {|f| f.puts "# Where the magic happens!" }

    File.open("#{folder}/Gemfile", "wb+") do |f|
      f << RubyChopped.gemfile_string
    end
    
    puts ""
    puts "Your basket is ready. Open the Gemfile to see what you'll be working with today."

    puts ""
    puts "You'll want to cd into #{folder} and run 'bundle install' first"
    puts "Enjoy!"
  end

  def gemfile_array
    gas = []
    gas << "source \"http://rubygems.org\""
    gas << ""
    
    gems = random_gems
    gems.each do |g|
      # Janky way to pull the name
      g = g.first
      name = g["full_name"].split(/-\d\.\d\.\d/).first
      number = g["number"]
      summary = g["summary"]
      
      gas << "# #{name}: #{summary}"
      gas << "gem \"#{name}\", \"#{number}\""
      gas << ""
    end
    
    gas << "# ENJOY!"
    
    gas
  end
  
  def gemfile_string
    gemfile_array.join("\n")
  end
    
  def random_gems(limit=2)
    gems = fetch_gems
    gems = pick_gems(gems, limit)
  end
  
  def pick_gems(gems, limit)
    limit.to_i.times.collect do 
      g = gems.delete_at(rand(gems.size)) 

      # Skip bundler and rails
      if g.first["full_name"][/(bundler|rails)/]
        pick_gems(gems, 1).first
      else
        g
      end
    end
  end
  
  def fetch_gems
    gems_json = JSON.parse(RestClient.get("http://rubygems.org/api/v1/downloads/top.json", :accepts => :json))
    gems = gems_json["gems"]    
    gems
  end
end
