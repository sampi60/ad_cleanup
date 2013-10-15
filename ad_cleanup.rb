# You can use this script if you were deploying on Alwaysdata with Capistrano and already deleted all 
# directories and files from /home/account_name/www/project_name folder (using ex. FileZilla) but it left some
# folders with symlinks, such as:

#  -- www
#     `-- project_name
#         |-- current -> /home/account_name/www/project_name/releases/20131014083207
#         `-- releases
#             |-- 20131014081055
#             |   |-- log -> /home/account_name/www/project_name/shared/log
#             |   |-- public
#             |   |   `-- system -> /home/account_name/www/project_name/shared/system
#             |   `-- tmp
#             |       `-- pids -> /home/account_name/www/project_name/shared/pids
#             `-- 20131014083207
#                 |-- log -> /home/account_name/www/project_name/shared/log
#                 |-- public
#                 |   `-- system -> /home/account_name/www/project_name/shared/system
#                 `-- tmp
#                     `-- pids -> /home/account_name/www/project_name/shared/pids

# Before run change change project_name and account_name variables below.
# Than connect to your alwaysdata account with ssh, copy this file wherever you want and run:
# ruby -r './ad_cleanup.rb' -e 'cleanup'

# ######################################################################################


def cleanup

  # ----------------------------------------------
  account_name = 'your account name' # <-- change this!
  project_name = 'your project name' # <-- change this!
  # ----------------------------------------------

  project_dir = "/home/#{account_name}/www"
  Dir.chdir(project_dir)

  Dir.entries(project_name).select do |entry1|

    dir1 = File.join(project_name,entry1) #dir2 = "#{project_name}/#{entry1}"
    if is_directory?(dir1)
      Dir.entries(dir1).select do |entry2|
        
        dir2 = File.join(dir1,entry2) #dir2 = "#{project_name}/#{entry1}/#{entry2}"
        if is_directory?(dir2)
          Dir.entries(dir2).select do |entry3|
            
            dir3 = File.join(dir2,entry3) #dir3 = "#{project_name}/#{entry1}/#{entry2}/#{entry3}"
            if is_directory?(dir3)
              Dir.entries(dir3).select do |entry4|
                delete_file(File.join(dir3,entry4))
              end
            end

            delete_file(dir3)
            delete_dir(dir3)
          end
        end

        delete_file(dir2)
        delete_dir(dir2)
      end
    end

    delete_file(dir1)
    delete_dir(dir1)
  end

  delete_dir(project_name)
end


def is_directory?(dir)
  File.directory? dir and !(dir.reverse.split('/')[0] == '.' || dir.reverse.split('/')[0] == '..')
end

def delete_file(file)
  if File.symlink?(file)
    puts "deleting symlink: #{file}"
    File.unlink(file)
  elsif File.file?(file)
    puts "deleting file: #{file}"
    File.delete(file)
  end
end

def delete_dir(dir)
  if is_directory?(dir)
    puts "deleting directory: #{dir}"
    Dir.delete(dir)
  end
end
