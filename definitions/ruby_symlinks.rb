#
# Cookbook Name:: ruby
# Definition:: ruby_symlinks
#
# Copyright 2010, FindsYou Limited
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

define :ruby_symlinks, :action => :create, :force => false, :path => '/usr/bin' do
  rv = params[:name].to_s
  rv = rv.slice(0..2).delete(".") if node[:platform] == "gentoo"

  ruby_block "do_links" do
    block do
      case node[:platform]
      when "ubuntu","debian"
        cmd = Chef::ShellOut.new(
          %Q[ update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby#{rv} 400 \
              --slave /usr/share/man/man1/ruby.1.gz ruby.1.gz \
              /usr/share/man/man1/ruby#{rv}.1.gz \
              --slave /usr/bin/ri ri /usr/bin/ri#{rv} \
              --slave /usr/bin/irb irb /usr/bin/irb#{rv} \
              --slave /usr/bin/gem gem /usr/bin/gem#{rv} ]
          ).run_command
        unless cmd.exitstatus == 0 or cmd.exitstatus == 2
          Chef::Application.fatal!("Failed to update-alternatives for ruby!")
        end
      else
        %w( ruby irb erb ri testrb rdoc gem rake ).each do |name|
          path = File.join(params[:path], name)
          scope = self

          link path do
            to path + rv
            action params[:action]

            unless params[:force]
              not_if do
                if File.exists?(path) and not File.symlink?(path)
                  scope.log "Not modifying non-symbolic-link #{path}"
                  true
                end
              end
            end
          end
        end
      end
    end
  end
end
