require 'rest-client'
require 'json'

module RubyChopped
  def self.gemfile_array
    gas = []
    gas << "http://rubygems.org"
    
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
  
  def self.gemfile_string
    gemfile_array.join("\n")
  end
    
  def self.random_gems(limit=2)
    gems = fetch_gems
    limit.to_i.times.collect{ gems.delete_at(rand(gems.size)) }
  end
  
  def self.fetch_gems
    gems_json = JSON.parse(RestClient.get("http://rubygems.org/api/v1/downloads/top.json", :accepts => :json))
    gems = gems_json["gems"]    
    gems
  end
end
