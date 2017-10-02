#Copy from /usr/nexus/bin/nexus to /etc/init.d/

file '/etc/init.d/nexus' do
  content IO.read('/usr/nexus/bin/nexus')
  action :create
end

#Insert strings into file, if such strings already haven't exist

ruby_block 'insert_line' do
  block do
    file = Chef::Util::FileEdit.new("/etc/init.d/nexus")
    file.insert_line_if_no_match("NEXUS_HOME=/usr/nexus", "NEXUS_HOME=/usr/nexus")
    file.write_file
  end
end

ruby_block 'insert_line2' do
  block do
    file = Chef::Util::FileEdit.new("/etc/init.d/nexus")
    file.insert_line_if_no_match("RUN_AS_USER=nexus", "RUN_AS_USER=nexus")
    file.write_file
  end
end

#Recursive change of owner and group for the directory /usr/nexus

directory "/usr/nexus" do
  owner 'nexus'
  group 'nexus'
  recursive true
end

#Do chmod 755 for the below file

file "/etc/init.d/nexus" do
  owner 'nexus'
  group 'nexus'
  mode '0755'
end

ruby_block 'insert_line3' do
  block do
    file = Chef::Util::FileEdit.new("/usr/nexus/bin/jsw/conf/wrapper.conf")
    file.insert_line_if_no_match("wrapper.java.command=/usr/java/jdk1.8.0_131/jre/bin/java", "wrapper.java.command=/usr/java/jdk1.8.0_131/jre/bin/java")
    file.write_file
  end
end

ruby_block 'insert_line4' do
  block do
    file = Chef::Util::FileEdit.new("/usr/nexus/conf/nexus.properties")
    file.insert_line_if_no_match("nexus-webapp-context-path=/nexus", "nexus-webapp-context-path=/nexus")
    file.write_file
  end
end

execute 'add_nexus' do
  command 'chkconfig --add nexus'
end

execute 'nexus' do
  command 'chkconfig --levels 345 nexus on'
  notifies :run, 'execute[nexus_firewall]', :immediately
  notifies :run, 'execute[reload_firewall]', :immediately
  notifies :run, 'bash[start_nexus]', :immediately
end

execute 'nexus_firewall' do
  command 'firewall-cmd --permanent --add-port=10050/tcp'
  action :nothing
end

execute 'reload_firewall' do
  command 'firewall-cmd --reload'
  action :nothing
end

bash 'start_nexus' do
  user 'nexus'
  cwd '/usr/nexus/'
  code <<-EOH
    ./bin/nexus console
    ./bin/nexus start
    EOH
  action :nothing
end

