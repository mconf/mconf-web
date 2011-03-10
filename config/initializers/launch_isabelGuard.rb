isabel_dir = "/usr/local/isabel/"

if File.exist?(isabel_dir)
  ENV['ISABEL_DIR'] = isabel_dir
  ENV['ISABEL_USER_DIR'] = ENV['HOME'] + "/.isabel"
  ENV['ISABEL_SESSIONS_DIR'] = ENV['ISABEL_USER_DIR']+"/sessions/4.11"
  ENV['ISABEL_CONFIG_DIR'] = ENV['ISABEL_USER_DIR']+"/config"
  ENV['ISABEL_PROFILES_DIR'] = ENV['ISABEL_CONFIG_DIR'] +"/profiles/4.11"
 
 
 #First of all we check if IsabelGuard is executing with the command fp (equivalent to ps -ef)
  fp_isabelGuard = "/usr/local/bin/fp IsabelGuard"
  fp_IO = IO.popen(fp_isabelGuard)
  output = fp_IO.readlines
  #Only launch IsabelGuard if it is not launched already
  if output.length <= 1     #the first line is not a command is the titles
      isabelguard_libs = " /usr/local/isabel/libexec/isabel_tunnel.jar:/usr/local/isabel/extras/libexec/xmlrpc/commons-logging-1.1.jar:" +
          "/usr/local/isabel/extras/libexec/xmlrpc/ws-commons-util-1.0.2.jar:/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-common-3.1.jar:" +
          "/usr/local/isabel/extras/libexec/xmlrpc/servlet-api.jar:/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-client-3.1.jar:" +
          "/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-server-3.1.jar:" + Rails.root.to_s + "/lib/mysql-connector-java-5.1.5-bin.jar:" +
          "/usr/local/isabel/libexec/isabel_xlimservices.jar:/usr/local/isabel/libexec/xedl.jar:" +
          "/usr/local/isabel/libexec/isabel_xlim.jar:/usr/local/isabel/lib/images/xlim/:"+
          "/usr/local/isabel/libexec/isabel_lib.jar -Dprior.config.file=/usr/local/isabel/lib/xlimconfig/priorxedl.cfg"+
          " -Disabel.dir=/usr/local/isabel/ -Disabel.profiles.dir=/home/ebarra/.isabel/config/profiles/4.11" +
          " -Disabel.sessions.dir=/home/ebarra/.isabel/sessions/4.11 -Disabel.user.dir=/home/ebarra/.isabel" +
          " -Disabel.config.dir=/home/ebarra/.isabel/config "
      command_isabelguard = "java -cp " + isabelguard_libs + " services/isabel/services/isabelGuard/IsabelGuard > " + ENV['ISABEL_USER_DIR'] +
                            "/logs/isabelGuard.log 2>&1 &"
      object_IO = IO.popen(command_isabelguard)
   end
end

