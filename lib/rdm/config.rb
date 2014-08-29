require 'yaml'

module RDM::Config
  def self.loadConfig
    @config = YAML.load_file("/etc/rdm/rdm.conf")
  end

  def self.get(var)
    if not defined? @config
      loadConfig
      @config[var]
    else
      @config[var]
    end
  end

  def self.getSessionList
    filepaths = Dir["/usr/share/xsessions/*"]
    sessions = []
    filepaths.each do |filepath|
      sessions.push(File.basename(filepath, ".*"))
    end
    return sessions
  end
end
