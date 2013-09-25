metadata :name => "varnish",
         :description => "Varnish Agent Plugin",
         :author => "Leonardo Rodrigues de Mello <l@lmello.eu.org>",
         :license => "ASL 2.0",
         :version => "0.1",
         :url => "http://github.com/lmello/mcollective-varnish-agent",
         :timeout => 5

action "purge", :description => "Purge the specified url from varnish cache" do
     # Example Input
     input :url,
           :prompt => "URL to be purged",
           :description => "The complete url you want to purge\n ex: http://example.com/images/image2.jpg",
           :type => :string,
           :validation => '^http:\/\/.*$',
           :optional => false,
           :maxlength => 250
     input :debug, 
           :prompt => "Use debug",
           :description => "Enable debug, default: false",
           :type => :boolean,
           :optional => :true
           

     # Example output
     output :error,
            :description => "Reason for failure described in status",
            :display_as => "error",
            :default => ""
     output :urlpurged,
            :description => "URL purged",
            :display_as => "purged"
     output :purge_cmd,
            :description => "Command used to purge",
            :display_as => "purge_cmd"
end

#action "vcl", :description => "Command to reload or show the varnish vcl" do
#end
#
#action "stats", :description => "Get some statistics from the varnish server" do
#end
