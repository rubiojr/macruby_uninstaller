#!/usr/bin/env ruby
require 'fileutils'

begin
  
  LOG='/tmp/macruby_uninstaller_log'
  BACKUP_DIR="/tmp/MacRuby_Uninstaller_Backup_#{Time.now.strftime('%F_%H%M%S')}"
  Dir.mkdir BACKUP_DIR

  File.open(LOG, 'w') do |f|
    IO.read(File.join(File.dirname(__FILE__), 'files')).each_line do |l|
      file = l.chomp.strip
      if not File.exist?(file) and not File.symlink?(file)
        f.puts "Skipping non existant file/dir #{file}"
        next
      end
      if File.directory? file
        dest_dir = File.join(BACKUP_DIR, file)
        FileUtils.mkdir_p(dest_dir)
        f.puts "backing up directory: #{file} to #{dest_dir}"
        FileUtils.cp_r(file, File.dirname(dest_dir))
        f.puts "removing directory: #{file}"
        FileUtils.rm_rf(file)
      else
        dest_dir = File.join(BACKUP_DIR, File.dirname(file))
        FileUtils.mkdir_p(dest_dir) if not File.exist?(dest_dir)
        f.puts "backing up file: #{file} to #{dest_dir}"
        FileUtils.cp(file, File.join(BACKUP_DIR, file))
        f.puts "removing file: #{file}"
        FileUtils.rm(file)
      end
    end
    f.puts "\n\nMacRuby uninstalled succesfully!"
  end

rescue Exception => e
  `echo "Something really bad happened" > /tmp/macruby_uninstaller_error`
  `echo "#{e.message}" >> /tmp/macruby_uninstaller_error`
  `echo "#{e.backtrace}" >> /tmp/macruby_uninstaller_error`
  exit 1
end
