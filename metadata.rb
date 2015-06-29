# encoding: UTF-8
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name             'jboss'
maintainer       'Stefano Harding'
maintainer_email 'riddopic@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures JBOSS'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.2'

%w[amazon centos debian fedora oracle redhat ubuntu].each { |os| supports os }

depends 'apt'
depends 'ark'
depends 'garcon'
depends 'java'
depends 'logrotate'
depends 'yum'
