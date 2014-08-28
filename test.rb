require 'etc'
require 'shadow'
require 'webkit'
require 'erb'

def startXServer
  Process.fork do 
    exec("/usr/bin/X")
  end
  if waitForXServer
  else
  end
end

def waitForXServer
  for i in 0..60
    begin
      require 'gtk2'
    rescue
      sleep(1)
    end
  end
end

def authenticate(username, password)
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

def getSessionList
  filepaths = Dir["/usr/share/xsessions/*"]
  sessions = []
  filepaths.each do |filepath|
    sessions.push(File.basename(filepath, ".*"))
  end
  return sessions
end

def login(username)
  pwnam = Etc.getpwnam(username) 
  Etc.endpwent()

  xauth = pwnam.dir + "/.Xauthority"

  Process.fork do
    Process.uid = pwnam.uid
    Process.gid = pwnam.gid
    Process.initgroups(pwnam.name, pwnam.gid)

    env = {}
    env['HOME'] = pwnam.dir
    env['PWD'] = pwnam.dir
    env['SHELL'] = pwnam.shell
    env['USER'] = pwnam.name
    env['LOGNAME'] = pwnam.name
    env['BANANA'] = "chhese"
    env['PATH'] = "/bin:/usr/bin:/usr/local/bin"
    env['DISPLAY'] = @display
    env['XAUTHORITY'] = xauth

    cmd = "exec /bin/bash -login ~/.xinitrc #{session}"
    exec(env, cmd)
  end

  Process.wait

  #KillAllClients and Restart?
end

module ErbData
  def self.sessions
    getSessionList
  end
end

@display = ":0.0"

startXServer

render = ERB.new(File.read("/home/sam/rdm/login.html.erb")).result(ErbData.instance_eval { binding })

webkit = WebKit::WebView.new
webkit.load_string(render, "text/html", "UTF-8", "file:///home/sam/rdm/login.html")

window = Gtk::Window.new
window.title = 'Ruby Webkit'

webkit.main_frame.add_js_api('login') do |username, password|
  if authenticate(username, password)
    login(username)
  else
    #Error Messages
  end
end

# # Exit when closing the window
window.signal_connect('destroy') { Gtk.main_quit }

# # Add the webview to the window
window.add webkit
window.show_all

Gtk.main
