maintainer       "Dale-Kurt Murray"
maintainer_email "dalekurt.murray@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures scalr"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "mysql"
depends "apache2"
depends "bind9"
depends "php"

%w{ ubuntu debian }.each do |os|
  supports os
end