file = cookbook_file '/etc/ssh/secret_key' do
	source 'secret_key'
	mode '0755'
	owner 'root'
	group 'root'
	action :nothing
	not_if {File.exist?('/etc/ssh/secret_key')}
end

#file.run_action(:create)

if File.exist?('/etc/ssh/secret_key')
	receivepass  = Chef::EncryptedDataBagItem.load("NexusDataBag", "password",IO.read('/etc/ssh/secret_key'))
	puts "\n ===== output is: #{receivepass['info']}"
	puts "\n ===== password is: #{receivepass['nexuspass']}"
end

ruby_block 'show node attribute' do
	block do
	  node.each do |item|; print '\n\nAttibute ->> ', item; end
	end
end





























