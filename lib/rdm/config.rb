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
    sessions = ["default"]
    filepaths.each do |filepath|
      sessions.push(File.basename(filepath, ".*"))
    end
    return sessions
  end

  def self.readSessionFile(session)
    info = {}
    File.open("/usr/share/xsessions/#{session}.desktop").each do |line|
      line = line.force_encoding("UTF-8")
      data = line.split('=')
      unless(data[1].nil?)
        info[data[0].strip] = data[1].strip      
      end
    end
    return info
  end 

  def self.read_dmrc_file
    info = {}
    File.open("#{ENV['HOME']}/.dmrc").each do |line|
      line = line.force_encoding("UTF-8")
      data = line.split('=')
      unless(data[1].nil?)
        info[data[0].strip] = data[1].strip      
      end
    end
    return info['Session']
  end
  
  def self.sessionExec(session)
    if session == "default"
      begin
        session = read_dmrc_file
      rescue
        session = getSessionList()[1] 
      end
    end
    info = readSessionFile(session) 
    info["Exec"]
  end  
end
