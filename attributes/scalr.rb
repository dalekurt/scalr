tarball = "scalr-2.2.1.tar.gz"

set_unless[:scalr][:installation_path] = "/root"
set_unless[:scalr][:web_path] = "/var/www"
set_unless[:scalr][:tarball_url] = "http://scalr.googlecode.com/files/http://scalr.googlecode.com/files/#{tarball}"
set_unless[:scalr][:tarball_checksum] = "c7c28d84950c0bd79fd1a311c0967fa820516ae1"
set_unless[:scalr][:tarball] = tarball
set_unless[:scalr][:dirname] = "scalr"
set_unless[:scalr][:user] = "ubuntu"
set_unless[:scalr][:group] = "ubuntu"