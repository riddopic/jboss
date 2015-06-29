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

jboss_module 'com.oracle.jdbc' do
  resource_url 'http://repo.mudbox.dev/jboss/ojdbc6.jar'
  dependencies 'javax.api,javax.transaction.api'
end

jboss_jdbc_driver 'oracle' do
  driver_module_name              'com.oracle.jdbc'
  driver_class_name               'oracle.jdbc.OracleDriver'
  driver_xa_datasource_class_name 'oracle.jdbc.xa.client.OracleXADataSource'
end

jboss_datasource 'OracleDS' do
  jndi_name                     'java:jboss/jdbc/protoOracleDatasource'
  connection_url                'jdbc:oracle:thin:@db.example.com:1521:JBPAJ'
  driver_name                   'oracle-ojdbc6'
  min_pool_size                  15
  max_pool_size                  350
  user_name                     'jboss'
  password                      'jboss'
  idle_timeout_minutes           15
  query_timeout                  350
  prepared_statements_cache_size 150
  use_java_context               true
end
