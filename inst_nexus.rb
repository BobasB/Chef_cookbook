########################################
#
#install and configure nexus
#
#######################################
#===== download and install nexus =====
ruby_block 'check if nexus install' do
    block do
	if File.exist?('/usr/nexus-2.14.4-03')
	    puts "\n Folder exist, nexus already install, two steps omitted \n"
	else puts "\n Dowload and install nexus \n"
	end
    end	
end
remote_file '/usr/nexus-2.14.4-03-bundle.tar.gz' do
    source 'https://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.14.4-03-bundle.tar.gz'
    owner 'root'
    group 'root'
    mode '755'
    not_if { File.exist?('/usr/nexus-2.14.4-03-bundle.tar.gz') }
end
execute 'extract_nexus-2.14.4-03-bundle_tar.gz' do
    subscribes :run, 'remote_file[/usr/nexus-2.14.4-03-bundle.tar.gz]', :immediately
    command 'tar -xvzf nexus-2.14.4-03-bundle.tar.gz'
    user 'root'
    cwd '/usr'
end
#########################################
#===== change owner of directories =====
	execute 'change owner nexus' do
	    command 'chown -R nexus:nexus /usr/nexus-2.14.4-03'
	    user 'root'
	    action :nothing
	end
	directory "/usr/nexus-2.14.4-03" do #change owner for nexus folder
            recursive true  #??? dont work for subdirectories!!!
	    owner 'nexus'
            group 'nexus'
	    notifies :run, 'execute[change owner nexus]', :immediately
        end
	execute 'change owner sonatype' do
            command 'chown -R nexus:nexus /usr/sonatype-work'
            user 'root'
            action :nothing
        end
	directory "/usr/sonatype-work" do #change owner for sonatype folder
            owner 'nexus'
            group 'nexus'
            recursive true  #??? dont work 
	    notifies :run, 'execute[change owner sonatype]', :immediately
        end
#make link
	link '/usr/nexus' do
            to '/usr/nexus-2.14.4-03'
        end
#make service link
	link '/etc/init.d/nexus' do
	    to '/usr/nexus-2.14.4-03/bin/nexus'
	end
#content ::File.open('/usr/nexus/bin/nexus').read

#######################################
#===== replace line to configure nexus =====
	ruby_block 'insert_line' do
	    block do
		file = Chef::Util::FileEdit.new("/etc/init.d/nexus")
		file.search_file_replace_line(/NEXUS_HOME=.*/, "NEXUS_HOME=/usr/nexus")
		file.search_file_replace_line(/#RUN_AS_USER=.*/, "RUN_AS_USER=nexus")
		file.write_file
		file2 = Chef::Util::FileEdit.new("/usr/nexus/conf/nexus.properties")
		file2.search_file_replace_line("nexus-webapp-context-path=/nexus", "nexus-webapp-context-path=/")
		file2.write_file
	    end
	end

#end #close if statement
#######################################
#######################################
#===== start as a service =====
service 'nexus' do
	notifies :run, 'execute[nexus console]', :immediately
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end
execute 'nexus console' do
	timeout 300
	ignore_failure true
	command 'sudo -u nexus ./usr/nexus/bin/nexus console'
	command 'sudo -u nexus ./usr/nexus/bin/nexus start'
	action :nothing
end
######################################
#===== cookbook delimiter =====
ruby_block 'delimiter' do
	block do
	    print "\n\n"; (1..40).each do |val|; print '='; end
	    print "\nEND OF NEXUS COOKBOOK"
	end
end
######################################
######################################
                            





































