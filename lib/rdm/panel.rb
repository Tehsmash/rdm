module RDM::Panel
  module ErbData
    def self.sessions
      RDM::Config.getSessionList
    end
  end

  def self.renderERB(path)
    return ERB.new(File.read(path)).result(ErbData.instance_eval { binding })
  end

  def self.new
    unless defined? @window
      render = renderERB(RDM::Config.get("themepath") + "/login.html.erb")

      webkit = WebKit::WebView.new
      webkit.load_string(render, "text/html", "UTF-8", "file://#{RDM::Config.get("themepath")}/login.html.erb")

      @window = Gtk::Window.new
      @window.title = 'RDM'

      addJSHooks webkit

      # Add the webview to the window
      @window.add webkit
      @window.show_all
    end
  end

  def self.run
    Gtk.main
  end

  def self.addJSHooks(webkit)
    webkit.main_frame.add_js_api('login') do |username, password|
      if authenticate(username, password)
        login(username)
      else
        #Error Messages
      end
    end

    webkit.main_frame.add_js_api('shutdown') do
      RDM.shutdown
    end

    webkit.main_frame.add_js_api('reboot') do
      RDM.reboot
    end
  end

  def self.clean
  end

  def self.hide
    @window.hide_all
    iterate
  end

  def self.show
    @window.show_all
    iterate
  end

  def self.iterate
    while(Gtk.events_pending?)
      Gtk.main_iteration
    end
  end
end
