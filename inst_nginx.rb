#########################################
#
#===== install and configure nginx =====
#
#########################################
#===== install dependensy =====
package 'epel-release' do
	action :install
end
########################################
#===== install nginx =====
package 'nginx' do
	action :install
end
########################################
#===== copy configuration file =====
cookbook_file '/etc/nginx/nginx.conf' do
	source 'nginx.conf'
	mode '0644'
	action :create
end
########################################
#===== create log file =====
file '/etc/nginx/nginx.error_log' do
	owner 'root'
	group 'root'
	mode '0644'
	action :create
end

########################################
#===== start service =====
service 'nginx' do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end

########################################
#===== cookbook delimiter =====
ruby_block 'delimiter' do
	block do
	    a = '='
	    while true do; a = a + '='; if a.length() == 40; print "\n\n", a; break; end; 
	    end; print "\nEND OF NGINX COOKBOOK" 
	end
end


























































