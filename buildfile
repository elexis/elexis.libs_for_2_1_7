#!/usr/bin/ruby 
# encoding: utf-8
# Copyright 2013 by Niklaus Giger <niklaus.giger@member.fsf.org
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Here add support for creating a p2site for all needed libraries not found in a standard Eclipse RCP checkout

require "buildr4osgi"
require "buildr/bnd"
require 'fileutils'

Version_P2_Site = "2.1.7"
Category        = 'elexis.libraries'
FeatureGroup    = 'elexis.libs_for_2_1_7'
Label           = "Foreign libraries for Elexis 2.1.7"
Description     = "Libraries needed to build and run Elexis 2.1.7"

repositories.remote << 'http://repo1.maven.org/maven2'

module P2_Util
  @@library_jars = []
  
  ENV['P2_EXE'] = ENV['OSGi'] if !ENV['P2_EXE']

  ss = [ ENV['P2_EXE'],
    'c:/Program Files/eclipse', # Windows
    '/Applications/eclipse',    # MacOSX
    '/usr/local/lib/eclipse',   # Linux user overridden
    '/usr/lib/eclipse',         # Linux default (at least for Debian)
  ]
  ss.each{ |x|
    if x != nil && Dir.glob(File.join(x, 'eclipse*')).size > 0 then
      ENV['P2_EXE'] = x
      break
    end
    }

  puts "Setup: P2_EXE is #{ENV['P2_EXE']}"
  errorMsg = "an Eclipse application must be found inside environment variable P2_EXE!"
  if !ENV['P2_EXE']
    puts errorMsg
    exit 3
  end
  fName = File.join(ENV['P2_EXE'], 'eclipse')
  if (!File.exists?(fName) && !File.exists?(fName + '.exe'))
    puts errorMsg
    exit 3
  end

  def P2_Util::addLibraryProject(project_id)
    trace "P2Site: addLibraryProject project_id is #{project_id}"
    @@library_jars << project_id
  end
  
  def P2_Util::getLibraryProjects
    @@library_jars
  end
  
end

def add_library_project(id, artifact_id, exports, bnd_opts=nil)
  version =  artifact_id.split(':')[-1]
  src = %(
#{id.upcase.gsub('.','_')} = '#{artifact_id}'
desc 'Foreign library #{id}'
define '#{id}' do
  project.version = '#{version}'
  project.group = '#{FeatureGroup}'
  package(:bundle).tap do |bnd|
    #{bnd_opts}
    bnd['Import-Package'] = "*;resolution:=optional"
    bnd['Export-Package'] = "#{exports};version=#{version}"
    bnd.classpath_element '#{artifact_id}'
  end
  package(:jar)
end
P2_Util::addLibraryProject('#{id}')
) 
  eval(src)
end
 # don't add the the moment slf4j and logback libs as
  # ch.qos.logback.slf4j_1.0.0.v20120123-1500.jar does not have a direct maven equivalent
  # add_library_project ch.qos.logback.slf4j
add_library_project('org.apache.felix.gogo.command', 'org.apache.felix:org.apache.felix.gogo.command:jar:0.8.0','*')
add_library_project('org.apache.felix.gogo.runtime', 'org.apache.felix:org.apache.felix.gogo.runtime:jar:0.8.0','*')
add_library_project('org.apache.felix.gogo.shell', 'org.apache.felix:org.apache.felix.gogo.shell:jar:0.8.0','*')

add_library_project('org.apache.log4j', 
                    'log4j:log4j:jar:1.2.15',
                    'org.apache.log4j.*')

add_library_project('org.slf4j.log4j', 
		    'org.slf4j:slf4j-log4j12:jar:1.6.6',
                    'org.slf4j.*')

add_library_project('org.slf4j.api', 
                    'org.slf4j:slf4j-api:jar:1.6.6',
                    'org.slf4j.*')

add_library_project('org.slf4j.ext', 
                    'org.slf4j:slf4j-ext:jar:1.6.6',
                    'org.slf4j.*')

add_library_project('org.slf4j.jcl', 
		    'org.slf4j:slf4j-jcl:jar:1.6.6',
                    'org.slf4j.*')

add_library_project('org.slf4j.jul', 
                    'org.slf4j:jul-to-slf4j:jar:1.6.6',
                    'org.slf4j.*')

add_library_project('ch.qos.logback.classic', 
		    'ch.qos.logback:logback-classic:jar:1.0.7',
                    'ch.qos.logback.*')

add_library_project('ch.qos.logback.core', 
                    'ch.qos.logback:logback-core:jar:1.0.7',
                    'ch.qos.logback.*')

add_library_project('org.apache.bsf', 
                    'bsf:bsf:jar:2.4.0',
                    'org.apache.bsf.*')

add_library_project('org.apache.commons.io', 
                    'commons-io:commons-io:jar:2.4',
                    'org.apache.commons.io.*')

add_library_project('org.apache.commons.lang', 
                    'commons-lang:commons-lang:jar:2.4',
                    'org.apache.commons.lang.*')

add_library_project('org.apache.commons.logging', 
                    'commons-logging:commons-logging:jar:1.1.1',
                    'org.apache.commons.logging.*')

add_library_project('org.apache.xerces', 
                    'xerces:xercesImpl:jar:2.9.0',
                    'org.apache.xerces.*')

add_library_project('org.apache.xml.serializer', 
                    'xalan:serializer:jar:2.7.1',
                    'org.apache.xml.serializer.*')

add_library_project('org.apache.xml.resolver', 
                    'xml-resolver:xml-resolver:jar:1.2',
                    'org.apache.xml.resolver.*')

add_library_project('javax.ws.rs', 
                    'javax.ws.rs:jsr311-api:jar:1.1.1',
                    'javax.ws.rs.*')

add_library_project('javax.xml', 
                    'javax.xml:jaxp-api:jar:1.4.2',
                    'javax.xml.*')

add_library_project('javax.activation', 
                    'javax.activation:activation:jar:1.1.1',
                    '*')

add_library_project('javax.mail', 
                    'javax.mail:mail:jar:1.4',
                    '*')

add_library_project('org.jdom', 
		    'org.jdom:jdom:jar:1.1',
                    'org.jdom.*')

add_library_project('org.yaml.snakeyaml', 
                    'org.yaml:snakeyaml:jar:1.11',
                    'org.yaml.snakeyaml.*')

add_library_project('ch.elexis.mysql.connector', 
		    'mysql:mysql-connector-java:jar:5.1.21',
                    'com.mysql.jdbc.*')

add_library_project('ch.elexis.h2.connector', 
		    'com.h2database:h2:jar:1.3.170',
                    'org.h2.*')

add_library_project('ch.elexis.postgresql.connector', 
		    'postgresql:postgresql:jar:9.1-901-1.jdbc4',
                    'org.postgresql.*',
                    "bnd['Eclipse-RegisterBuddy'] = 'ch.rgw.utility'")

add_library_project('org.bouncycastle',
		    'org.bouncycastle:bcprov-jdk16:jar:1.46',
		    'org.bouncycastle.*')

add_library_project('bsh',
		    'org.beanshell:bsh:jar:2.0b4',
		    '*')

add_library_project('gnu.io', # GNU Lesser General Public License
		    'org.rxtx:rxtx:jar:2.1.7',
		    'gnu.io')

add_library_project('sysout.over.slf4j',   # http://projects.lidalia.org.uk/sysout-over-slf4j/
 'uk.org.lidalia:sysout-over-slf4j:jar:1.0.2',
 'uk.org.lidalia.sysoutslf4j.*'
)

define FeatureGroup+".site.feature" do
  project.version = Version_P2_Site
  f = project.package(:feature)
  f.plugins += P2_Util::getLibraryProjects.collect{ |libId| project(libId).package(:jar).to_s } 
  f.label = "foreign libraries for elexis"
  f.provider = "a lot of people"
  f.description = "Foreign libraries used to build and run Elexis"
  f.copyright   = "a lot of people"
  f.changesURL = "http://www.elexis.ch/changes"
  f.license = "Eclipse Public License Version 1.0"
  f.licenseURL = "http://eclipse.org/legal/epl-v10.html"
  f.update_sites << {:url => "http://www.elexis.ch/update", :name => "Elexis update site"}
  f.discovery_sites = [{:url => "http://www.elexis.ch/update2", :name => "Elexis discovery site"},
    {:url => "http://backup.elexis.ch//backup-update", :name => "Backup update site"}]
end

define 'elexis.libraries' do
  project.version = Version_P2_Site
  layout[:target] = File.expand_path(File.join(_, FeatureGroup))
  category = Buildr4OSGi::Category.new
  category.name = Category
  category.label = "Foreign libraries used to build and run Elexis"
  category.description = "Elexis-Foreign libraries"
  category.features << project(FeatureGroup + '.site.feature')
  package(:site).categories << category
  package(:p2_from_site)
  
  desc 'create a P2 update site for Elexis'
  task 'p2site' => package(:p2_from_site)
  
  check package(:p2_from_site), 'The p2site should have a site.xml' do
    File.should exist(File.join(path_to(:target,'p2repository/site.xml')))
  end
  check package(:p2_from_site), 'The p2site should have an artifacts.jar' do
    File.should exist(File.join(path_to(:target,'p2repository/artifacts.jar')))
  end
  check package(:p2_from_site), 'The p2site should have content.jar' do
    File.should exist(File.join(path_to(:target,'p2repository/content.jar')))
  end
  check package(:p2_from_site), 'The p2site should have a plugins directory' do
    File.should exist(File.join(path_to(:target,'p2repository/plugins')))
  end
  check package(:p2_from_site), 'The p2site should have a features directory' do
    File.should exist(File.join(path_to(:target,'p2repository/features')))
  end
end
