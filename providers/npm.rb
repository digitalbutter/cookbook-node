require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

action :install do
  # If we specified a version, and it's not the current version, move to the specified version
  if @new_resource.version != nil && @new_resource.version != @current_resource.version
    install_version = @new_resource.version
  # If it's not installed at all, install it
  elsif @current_resource.version == nil
    install_version = candidate_version
  end
  
  if install_version
    Chef::Log.info("Installing #{@new_resource} version #{install_version}")
    status = install_package(@new_resource.name, install_version)
    if status
      @new_resource.updated_by_last_action(true)
    end
  end
end

action :uninstall do
  if removing_package?
    Chef::Log.info("Removing #{@new_resource}")
    remove_package(@current_resource.name, @new_resource.version)
    @new_resource.updated_by_last_action(true)
  else
  end
end


# OBSOLETE
action :linstall do
  execute "install npm module locally" do
    command "npm install #{new_resource.name}"
  end
end


# OBSOLETE
action :luninstall do
  execute "uninstall npm module locally" do
    command "npm uninstall #{new_resource.name}"
  end
end

def load_current_resource
  @current_resource = Chef::Resource::NodeNpm.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.version(nil)
  
  unless current_installed_version.nil?
    @current_resource.version(current_installed_version)
  end
  
  @current_resource
end

def current_installed_version
  @current_installed_version ||= begin
    delimeter = /@/
    version_check_cmd = "npm -g list --parseable --long |  grep -i -o -P -e #{@new_resource.name}@\[0-9]*.\[0-9]*.\[0-9]*"
    p = shell_out!(version_check_cmd)
    p.stdout.split(delimeter)[1].strip
  rescue Chef::Exceptions::ShellCommandFailed
  end
end

def candidate_version
  @candidate_version ||= begin
    # `npm search` does not return versions yet
    @new_resource.version||'latest'
  end
end

def install_package(name, version)
  v = "@#{version}" unless version == 'latest'
  shell_out!("npm -g install #{name}#{v}")
end

def removing_package?
  if @current_resource.version.nil?
    false # nothing to remove
  elsif @new_resource.version.nil?
    true # remove any version of a package
  elsif @new_resource.version == @current_resource.version
    true # remove the version we have
  else
    false # we don't have the version we want to remove
  end
end

def remove_package(name, version)
  shell_out!("npm -g uninstall #{@new_resource.name}")
end
