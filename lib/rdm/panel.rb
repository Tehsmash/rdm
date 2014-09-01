module RDM::Panel
  module ErbData
    def self.sessions
      RDM::Config.getSessionList
    end
  end

  def self.session
    @webkit.main_frame.exec_js("session()")
  end

  def self.renderERB(path)
    return ERB.new(File.read(path)).result(ErbData.instance_eval { binding })
  end

  def self.new
    unless defined? @window
      system("xsetroot -cursor_name left_ptr")

      render = renderERB(RDM::Config.get("themepath") + "/login.html.erb")

      @webkit = WebKit::WebView.new
      @webkit.load_string(render, "text/html", "UTF-8", "file://#{RDM::Config.get("themepath")}/login.html.erb")

      @webkit.settings.enable_default_context_menu = false

      @window = Gtk::Window.new
      @window.title = 'RDM'
      @window.set_default_size(@window.screen.width, @window.screen.height)
      @window.set_window_position Gtk::Window::POS_CENTER

      addJSHooks

      # Add the webview to the window
      @window.add @webkit
      @window.show_all
    end
  end

  def self.run
    Gtk.main
  end

  def self.addJSHooks
    @webkit.main_frame.add_js_api('login') do |username, password|
      begin
        if RDM.authenticate(username, password)
          RDM.login(username)
        else
          message("Incorrect Username or Password!", "error") 
        end
      rescue Exception => e
        system("echo 'Error = #{e}' >> /root/rdmlog")
        message("Something Went Wrong!", "error") 
      end
    end

    @webkit.main_frame.add_js_api('shutdown') do
      RDM.shutdown
    end

    @webkit.main_frame.add_js_api('reboot') do
      RDM.reboot
    end
  end

  def self.message(message, type)
    @webkit.main_frame.exec_js("message('#{message}','#{type}')")
  end

  def self.clean
    @webkit.main_frame.exec_js("clean()")
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
