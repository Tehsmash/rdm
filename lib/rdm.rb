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
      Process.uid = pwnam.uid
      Process.gid = pwnam.gid
      Process.initgroups(pwnam.name, pwnam.gid)
  end

  def self.login(username)
    pwnam = Etc.getpwnam(username) 
    Etc.endpwent()

    xauth = pwnam.dir + "/.Xauthority"

    Process.fork do
      RDM.switchuser pwnam

      env = {}
      env['HOME'] = pwnam.dir
      env['PWD'] = pwnam.dir
      env['SHELL'] = pwnam.shell
      env['USER'] = pwnam.name
      env['LOGNAME'] = pwnam.name
      env['PATH'] = RDM::Config.get("defaultpath")
      env['DISPLAY'] = RDM::XServer.display
      env['XAUTHORITY'] = xauth

      #cmd = "exec /bin/bash -login exec awesome"
      exec(env, "/usr/bin/awesome")
    end

    RDM::Panel.hide

    Process.wait

    RDM::Panel.clean

    RDM::Panel.show
  end
end

require 'rdm/xserver'
require 'rdm/panel'
require 'rdm/config'
