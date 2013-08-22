#
# Cookbook Name:: npm-repo
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "/usr/local/npmjs" do
  mode 00666
  owner "root"
  group "root"
  action :create
end

git "npmjs" do
  repository "git://github.com/isaacs/npmjs.org.git"
  reference "master"
  destination "/usr/local/npmjs/npmjs.org"
  action :sync
end


bash "setup_couchapp" do
  cwd "/usr/local/npmjs/npmjs.org"
  code <<-EOH
    npm install couchapp -g
    npm install
    curl -X PUT http://localhost:5984/registry
    couchapp push repository/app.js http://localhost:5984/registry
    couchapp push www/app.js http://localhost:5984/registry
    curl -X DELETE http://localhost:5984/registry
    curl -X POST http://127.0.0.1:5984/_replicate  -d '{"source":"http://isaacs.iriscouch.com/registry/", "target":"registry", "continuous":true, "create_target":true}' -H "Content-Type: application/json"
  EOH
end

