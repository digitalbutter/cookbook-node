action :install do
  execute "install npm module" do
    command "sudo npm install #{new_resource.name}"
  end
end

action :uninstall do
  execute "uninstall npm module" do
    command "sudo npm uninstall #{new_resource.name}"
  end
end

action :linstall do
  execute "install npm module locally" do
    command "npm install #{new_resource.name}"
  end
end

action :luninstall do
  execute "uninstall npm module locally" do
    command "npm uninstall #{new_resource.name}"
  end
end
