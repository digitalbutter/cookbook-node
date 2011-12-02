provider_for_init_style = {
  :upstart => Chef::Provider::Service::Upstart,
  :runit => Chef::Provider::Service::Init,
  :service => Chef::Provider::Service::Init
}

action :start do

  # Install dependency with npm
  if (not new_resource.dependency.empty?)
    new_resource.dependency.each do |dep|
      execute "install dependency module #{dep}" do
        command "sudo npm -g install #{dep}"
      end
    end
  end

  # Get the user's home
  user_home = (%x[cat /etc/passwd | grep #{new_resource.user} | cut -d":" -f6]).chomp
  user = new_resource.user || node[:node][:user] 

  case new_resource.init_style
  when :upstart
    # Create a node service for this program with upstart
    template "/etc/init/node-#{new_resource.name}.conf" do
      cookbook "node"
      source "upstart.erb"
      variables(
          :name => new_resource.name,
          :script => new_resource.script,
          :user => user,
          :user_home => user_home,
          :args => new_resource.args
      )
    end

    # Start the server
    service "node-#{new_resource.name}" do
      provider provider_for_init_style[:upstart]
      action :start
    end

  when :runit
    # if we passed this inside the runit_server block new_resource would have been evaluated in the context of the definition and thus fail
    template_options = {
          :name => new_resource.name,
          :script => new_resource.script,
          :user => user,
          :user_home => user_home,
          :args => new_resource.args
    }
    runit_service "node-#{new_resource.name}" do
      template_name "nodejs"
      cookbook "node"
      options template_options
    end
  when :init
    template "/etc/init.d/node-#{new_resource.name}" do
      mode "0755"
      source "init.sh.erb"
      cookbok "node"
      variables(
          :name => new_resource.name,
          :script => new_resource.script,
          :user => user,
          :user_home => user_home,
          :args => new_resource.args
      )
    end

    # Start the server
    service "node-#{new_resource.name}" do
      action :start
    end

  end
end

action :stop do
  service "node-#{new_resource.name}" do
    provider provider_for_init_style[new_resource.init_style]
    action :stop
  end
end

action :restart do
  service "node-#{new_resource.name}" do
    provider provider_for_init_style[new_resource.init_style]
    action :start
  end
end

action :enable do
  service "node-#{new_resource.name}" do
    provider provider_for_init_style[new_resource.init_style]
    action :enable
  end
end

action :disable do
  service "node-#{new_resource.name}" do
    provider provider_for_init_style[new_resource.init_style]
    action :disable
  end
end
