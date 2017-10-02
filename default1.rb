#On chefworkstation need to download jdk-8u131-linux-x64.rpm into the folder COOKBOOK_NAME/files/, then uploading it with below cookbook_file resource to chef node

cookbook_file '/root/jdk-8u131-linux-x64.rpm' do
  source 'jdk-8u131-linux-x64.rpm'
  owner 'root'
  group 'wheel'
  mode '755'
end

package 'jdk-8u131-linux-x64.rpm' do
  source '/root/jdk-8u131-linux-x64.rpm'
  action :install
end

#Download nexus-2.14.4-03-bundle.tar.gz from remote source
remote_file '/usr/nexus-2.14.4-03-bundle.tar.gz' do
  source 'https://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.14.4-03-bundle.tar.gz'
  owner 'root'
  group 'root'
  mode '755'
end

execute 'extract_nexus-2.14.4-03-bundle_tar.gz' do
  command 'tar -xvzf nexus-2.14.4-03-bundle.tar.gz'
  cwd '/usr'
  subscribes :run, 'remote_file[/usr/nexus-2.14.4-03-bundle.tar.gz]', :immediately
end

link '/usr/nexus' do
  to '/usr/nexus-2.14.4-03'
  link_type :symbolic
end

#Create a variable to load the data from 'passwords' data bag, data_bag_item
 is nexuspassword

passwords = data_bag_item('passwords', 'nexuspassword')

#Load data from passwords variable and select nexus_password
#To decrypt data_bag on chefnode need to do scp -r /root/chef-repo/.chef/my_secret_key root@chefnodeipaddress:/etc/chef/encrypted_data_bag_secret

user 'nexus' do
  manage_home true
  comment 'User nexus'
  home '/home/nexus'
  shell '/bin/bash'
  password passwords['nexus_password']
end

