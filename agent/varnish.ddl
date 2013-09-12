metadata :name => "varnish",
         :description => "Varnish Agent Plugin",
         :author => "Leonardo Rodrigues de Mello <l@lmello.eu.org>",
         :license => "ASL 2.0",
         :version => "0.1",
         :url => "http://github.com/lmello/mcollective-varnish-agent",
         :timeout => %TIMEOUT%

action "purgeurl", :description => "Purge the specified url from varnish cache" do
     # Example Input
     input :name,
           :prompt => "%PROMPT%",
           :description => "Purge the specified url from varnish cache",
           :type => %TYPE%,
           :validation => '%VALIDATION%',
           :optional => %OPTIONAL%,
           :maxlength => %MAXLENGTH%

     # Example output
     output :name,
            :description => "%DESCRIPTION%",
            :display_as => "%DISPLAYAS%"
end

action "purgeregex", :description => "Purge varnish cache using regular expressions" do
end

action "vcl", :description => "Command to reload or show the varnish vcl" do
end

action "stats", :description => "Get some statistics from the varnish server" do
end

action "start", :description => "Start the varnish service" do
end

action "stop", :description => "Stop the varnish service" do
end

action "restart", :description => "Restart the varnish service" do
end

action "reload", :description => "Reload the vcl" do
end
