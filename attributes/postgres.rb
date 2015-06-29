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

default[:jboss][:postgresql].tap do |postgresql|
  #
  # PostgreSQL Database Configuration
  #
  postgresql[:enabled] = false

  # PostgreSQL driver JDBC Module Name
  #
  postgresql[:mod_name] = 'org.postgresql'

  # PostgreSQL driver Module Dependencies
  #
  postgresql[:mod_deps] = ['javax.api', 'javax.transaction.api']

  postgresql[:jndi][:datasources] = [
    {
      jndi_name: 'java:jboss/datasources/test',
      server:    '127.0.0.1',
      port:       5432,
      db_name:   'test',
      db_user:   'test_user',
      db_pass:   'test_pass',
      pool_min:   5,
      pool_max:   20
    },
    {
      jndi_name: 'java:jboss/datasources/test2',
      server:    '127.0.0.1',
      port:       5432,
      db_name:   'test2',
      db_user:   'test_user',
      db_pass:   'test_pass',
      pool_min:   5,
      pool_max:   20
    }
  ]

  # Download location of JDBC connector
  #
  postgresql[:url] = 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1102-jdbc41/postgresql-9.3-1102-jdbc41.jar'

  # SHA-256 checksum of JDBC connector
  #
  postgresql[:checksum] = 'c4530047d03bac8295a9c19fbd7b893b5981edbcd8e52e1597fa2385deec272f'
end
