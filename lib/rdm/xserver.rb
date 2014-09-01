module RDM::XServer

  @display =":0"

  def self.createAuth
    xauthpath = "/var/lib/rdm"
    file = "#{xauthpath}/#{@display}.Xauth"

    system("mkdir -p #{xauthpath}")
    system("rm -f #{file}")
    system("touch #{file}")
    @mcookie = %x(dd if=/dev/random bs=16 count=1 2>/dev/null | hexdump -e \\"%08x\\")
    system("xauth -q -f #{file} add #{@display} . #{@mcookie}")
    return file
  end

  def self.start
    Process.fork do 
      exec("/usr/bin/X vt07 -auth /var/lib/rdm/:0.Xauth")
    end
    if wait
    else
    end
  end

  def self.display
    @display
  end

  def self.mcookie
    @mcookie
  end

  def self.wait
    for i in 0..60
      begin
        require 'gtk2'
        require 'webkit'
      rescue
        sleep(1)
      end
    end
  end

end
