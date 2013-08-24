#
# Cookbook Name:: npm-repo
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

git "#{Chef::Config['file_cache_path']}/npmjs.org" do
  repository "git://github.com/isaacs/npmjs.org.git"
  reference "master"
  action :sync
end

execute "npm install couchapp -g" do
  command "npm install couchapp -g"
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  action :run
end

execute "npm install semver" do
  command "npm install semver"
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  action :run
end

execute "npm install couchapp" do
  command "npm install couchapp"
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  action :run
end

bash "curl put" do
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  code <<-EOH
    curl -X PUT http://localhost:5984/registry
  EOH
end

execute 'push.sh' do
  command './push.sh'
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  environment({'npm_package_config_couch' => 'http://localhost:5984/registry'})
  action :run
end

execute 'load-views.sh' do
  command './load-views.sh'
  cwd "#{Chef::Config[:file_cache_path]}/npmjs.org"
  environment({'npm_package_config_couch' => 'http://localhost:5984/registry'})
  action :run
end

bash 'COPY _design/app' do
  code <<-EOH
    curl http://localhost:5984/registry/_design/scratch -X COPY -H destination:'_design/app'
  EOH
end
execute "setup_couchapp push repository" do
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  command "couchapp push registry/app.js http://localhost:5984/registry"
  action :run
end

execute "setup_couchapp push app.js" do
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  command "couchapp push www/app.js http://localhost:5984/registry"
  action :run
end

bash "curl post" do
  cwd "#{Chef::Config['file_cache_path']}/npmjs.org"
  code <<-EOH
    curl -X POST http://localhost:5984/_replicate -d '{"source":"http://isaacs.iriscouch.com/registry/", "target":"registry" }' -H "Content-Type: application/json"
  EOH
end
