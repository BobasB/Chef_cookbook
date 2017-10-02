##########################################
#
#configure node before inastall nexus
#
##########################################
##########################################
#===== update linux =====
update_sys = execute "yum update" do
  command "yum update"
  action :nothing
end

#update_sys.run_action(:run)

##########################################
#===== reload system attributes =====
ohai 'reload_task' do
	action :nothing
end

#########################################
##===== forward key for data bag =====
file = cookbook_file '/etc/ssh/secret_key' do
	source 'secret_key'
        mode '0755'
        owner 'root'
        group 'root'
        action :nothing
        not_if {File.exist?('/etc/ssh/secret_key')}
end

file.run_action(:create)

if File.exist?('/etc/ssh/secret_key')
	receiveval  = Chef::EncryptedDataBagItem.load("NexusDataBag", "password", IO.read('/etc/ssh/secret_key'))
        puts "\n ===== output is: #{receiveval['info']}"
end

##########################################
#===== change hostname withot reload =====
ch_file = ruby_block 'change hostname' do #change hostname in file
        block do
            file = Chef::Util::FileEdit.new('/etc/hostname')
            file.search_file_replace_line(node['hostname'],receiveval['nexushostname'])
            file.write_file
	end
        #notifies :run, 'ruby_block[change hostname]', :immediately
end
ch_ctl = bash 'change hostname' do #use bash and ctl
	user 'root'
	code <<-EOH
	h_name=$(cat /etc/hostname)
	hostnamectl set-hostname $h_name
	EOH
	notifies :reload, 'ohai[reload_task]', :immediately
	notifies :run, 'ruby_block[check hostname]', :immediately
	#action :noting
end
ruby_block 'check hostname' do	#view hostname after change
	#notifies :run, 'ruby_block[delimiter]', :immediately
	block do
	    puts "\n ===== output HOSTNAME: -=- #{node['hostname']} -=-"
	end
	action :nothing
end

#ch_file.run_action(:run)

##########################################
#===== add hostname to hosts =====
ruby_block 'add hosts' do
	block do
	file = Chef::Util::FileEdit.new("/etc/hosts")
	file.insert_line_if_no_match("#{node['ipaddress']} #{receiveval['nexushostname']}", "#{node['ipaddress']} #{receiveval['nexushostname']}")
	file.write_file
	end
end

#########################################
#=-= install java jdk =-=
yum_package 'java-1.7.0-openjdk-devel' do
	action :install
end

#########################################
#===== create user and group nexus =====
group receiveval['nexusgroup'] do
	action :create
end

user receiveval['nexususer'] do 
	manage_home true
	comment 'Create user to lunch service'
	home {"/home/#{receiveval['nexususer']}"}
	shell '/bin/bash'
	group receiveval['nexusgroup']
	password receiveval['nexuspass']
	system true
	action :create
	notifies :reload, 'ohai[reload_task]', :immediately
	#notifies :run, 'ruby_block[delimiter]', :immediately
end
=begin
usr_pass = receiveval['nexususer'].zip(receiveval['nexuspass'])
usr_pass.each do |user_val, pass_val|
user user_val do
        manage_home true
        home {"/home/#{user_val}"}
        password pass_val
        system true
        action :create
	end
end
=end
############################################
#===== past coockbook delimiter ======
ruby_block 'delimiter' do  #for better read log file
        block do
	  puts "\n\n"; for i in 1..40; print "="; end;
	  puts "\nEND OF START CONFIG COOKBOOK"
        end
	action :run
end
############################################
#######===== END =====######################
############################################










