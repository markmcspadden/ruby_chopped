require 'rest-client'
require 'fileutils'
require 'json'

module RubyChopped
  extend self

  def create(opts={})
    
    # Set pool of gems to fetch from
    if opts[:installed_gems]
      @gem_pool = :installed
    elsif opts[:all_gems]
      @gem_pool = :all
    else
      @gem_pool = :popular
    end
    
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
      f << RubyChopped.gemfile_string(opts[:limit] || 2)
    end
    
    puts ""
    puts "Your basket is ready. Open the Gemfile to see what you'll be working with today."

    puts ""
    puts "You'll want to cd into #{folder} and run 'bundle install' first"
    puts "Enjoy!"
  end

  def gemfile_array(limit)
    gas = []
    gas << "source \"http://rubygems.org\""
    gas << ""
    
    gems = random_gems(limit)
    gems.each do |g|
      # Fetch detailed information for selected gems
      info_json = JSON.parse(RestClient.get("http://rubygems.org/api/v1/gems/#{g}.json", :accepts => :json))
      number = info_json["version"]
      summary = info_json["info"].gsub("\n","\n# ")
      project_uri = info_json["project_uri"]
      documentation_uri = info_json["documentation_uri"]
      wiki_uri = info_json["wiki_uri"]
      mailing_list_uri = info_json["mailing_list_uri"]
      
      gas << "# #{g}: #{summary}"
      gas << "#    - Project page: #{project_uri}" unless project_uri.nil? || project_uri.empty?
      gas << "#    - Documentation: #{documentation_uri}" unless documentation_uri.nil? || documentation_uri.empty?
      gas << "#    - Wiki: #{wiki_uri}" unless wiki_uri.nil? || wiki_uri.empty?
      gas << "gem \"#{g}\", \"#{number}\""
      gas << ""
    end
    
    gas << "# ENJOY!"
    
    gas
  end
  
  def gemfile_string(limit)
    gemfile_array(limit).join("\n")
  end
    
  def random_gems(limit)
    gems = fetch_gems
    gems = pick_gems(gems, limit)
  end
  
  def pick_gems(gems, limit)
    limit.to_i.times.collect do 
      g = gems.delete_at(rand(gems.size)) 

      # Skip bundler and rails
      if g.match(/bundler|rails/)
        pick_gems(gems, 1).first
      else
        g
      end
    end
  end
  
  def fetch_gems
    case @gem_pool
    when :installed
      fetch_local_gems
    when :all
      fetch_all_gems
    when :popular
      fetch_popular_gems
    end
  end
  
  def fetch_all_gems
    puts "This might take awhile..."
    gems = Array.new
    gem_list = `gem list --remote`

    gem_list.split("\n").each { |g| gems << g.split(' ').first }
    gems
  end
  
  def fetch_local_gems
    gems = Array.new
    gem_list = `gem list`
    
    gem_list.split("\n").each { |g| gems << g.split(' ').first }
    gems
  end
  
  def fetch_popular_gems
    gems = Array.new
    gems_json = JSON.parse(RestClient.get("http://rubygems.org/api/v1/downloads/top.json", :accepts => :json))
    
    gems_json["gems"].each { |g| gems << g.first["full_name"].split(/-\d\.\d\.\d/).first }
    gems.uniq!
  end
end
