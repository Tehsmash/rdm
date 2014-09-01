require 'etc'
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
      exec("/bin/bash", "-c", "exec /bin/bash -login /etc/X11/Xsession #{session}")
    end

    RDM::Panel.hide

    Process.wait

    RDM::Panel.clean

    RDM::Panel.show
  end

  def self.reboot
    system("reboot")
  end

  def self.shutdown
    system("shutdown -h now")
  end
end

require 'rdm/xserver'
require 'rdm/panel'
require 'rdm/config'
