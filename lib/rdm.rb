require 'etc'
require 'socket'
require 'shadow'
require 'erb'

module RDM
  def self.authenticate(username, password)
    pwnam = Etc.getpwnam(username) 
    Etc.endpwent()

    if pwnam.passwd == "x"
      correct = Shadow::Passwd.getspnam(pwnam.name).sp_pwdp
      Shadow::Passwd.endspent()
    else
      correct = pwnam.passwd
    end

    encrypted = password.crypt(correct) 
    return encrypted == correct
  end

  def self.switchuser(pwnam)
      Process.initgroups(pwnam.name, pwnam.gid)
      Process::GID.change_privilege(pwnam.gid)
      Process::UID.change_privilege(pwnam.uid)
  end

  def self.users
    users = []
    user = Etc.getpwent()
    while not user.nil?
      if user.passwd == "x"
        sp = Shadow::Passwd.getspnam(user.name)
        unless ["!", "*"].include?(sp.sp_pwdp)
          users << user.name
        end
      end
      user = Etc.getpwent()
    end
    return users
  end

  def self.login(username)
    pwnam = Etc.getpwnam(username) 
    Etc.endpwent()

    xauthfile = pwnam.dir + "/.Xauthority"

    xauthcmd = "xauth -q -f #{xauthfile} add #{RDM::XServer.display} . #{RDM::XServer.mcookie}"

    Process.fork do
      RDM.switchuser pwnam

      ENV['TERM'] = "xterm"
      ENV['HOME'] = pwnam.dir
      ENV['PWD'] = pwnam.dir
      ENV['SHELL'] = pwnam.shell
      ENV['USER'] = pwnam.name
      ENV['LOGNAME'] = pwnam.name
      ENV['PATH'] = RDM::Config.get("defaultpath")
      ENV['DISPLAY'] = RDM::XServer.display
      ENV['XAUTHORITY'] = xauthfile

      Dir.chdir(pwnam.dir)

      system("rm -f #{xauthfile}")
      system("touch #{xauthfile}")
      system(xauthcmd)

      unless RDM::Panel.session == "default"
        system("echo '[Desktop]\nSession=#{RDM::Panel.session}' > ~/.dmrc")
      end

      session = RDM::Config.sessionExec(RDM::Panel.session)
      logincmd = RDM::Config.get("logincmd") % { session: session }
      exec("/bin/bash", "-c", logincmd)
    end

    RDM::Panel.hide

    Process.wait

    RDM::Panel.clean

    RDM::Panel.show
  end

  def self.reboot
    system(RDM::Config.get("rebootcmd"))
  end

  def self.shutdown
    system(RDM::Config.get("haltcmd"))
  end

  def self.stop
    puts "Attempting Stop!"
    system("rm /var/run/rdm.sock")
    RDM::Panel.destroy
  end

  def self.start
    thread = Thread.new {
      socket_start
    }
    RDM::Panel.new
    RDM::Panel.run
    puts "Panel Ended!"
    thread.join
  end

  def self.socket_start
    system("mkfifo /var/run/rdm.sock")
    input = open("/var/run/rdm.sock", "r+")
    loop do
      cmd = input.gets
      cmd = cmd.chomp
      puts "I received: #{cmd}"
      case cmd
      when "close"
        stop
        exit
      when "shutdown"
        stop
        shutdown
        exit
      when "reboot"
        stop
        reboot
        exit
      else
        puts "Nope..." 
      end
    end
  end

  def self.socket_send(msg)
    output = open("/var/run/rdm.sock", "w+")
    output.puts msg
    output.flush
  end
end

require 'rdm/xserver'
require 'rdm/panel'
require 'rdm/config'
