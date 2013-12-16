require 'open3'
require 'timeout'

$file=File.open("temp.gdb","w")

$command=["loadsession","storesession"]

while true

system("ls *.c")
print "Enter filename : "
$filename = gets
$filename = $filename.slice(0,$filename.length-1)
$foldername = $filename.gsub(".c","")
	if File.exist?($filename)
	system("gcc -g #{$filename} -o out")
	system("mkdir #{$foldername}")
	system("cp #{$filename} ./#{$foldername}/#{$filename} ")
	break
	else
	puts "File does not exist"
	end
end

class Gdbconsole
	def initialize
		@@stdin,@@stdout=Open3.popen2e("gdb out")
		@@buf="" 
		@@ch=""
	end

	def start
		@@buf=""
		while true
		@@ch = @@stdout.read(1)
		@@buf = @@buf + @@ch
			if(@@buf.include? "(gdb) ")
				break
			end
		end
		puts @@buf.slice(0,@@buf.length-6)
	end

	def read
		begin
				status = Timeout::timeout(0.5){
				@@ch=""
				@@ch=@@stdout.read(1)
				}
				rescue
				print "Enter input : "
				input = gets
				$file.print(input)
				@@stdin.write(input)
			read()
			return
		end

	end
	#-----------------------------
	def read_write
		begin
				status = Timeout::timeout(0.1){
				@@ch=""
				@@ch=@@stdout.read(1)
				}
						rescue
						input = $inst[$i]+"\n"
						$i += 1
							if $i > $inst.length
							return
							end
						@@stdin.write(input)
						puts(input)
						read_write()
				return
		end
	end
	#-------------------------------

	def load
	con = File.open("./#{$foldername}/#{$sessionname}.gdb","r")
	ton = con.read
	$inst = ton.split("\n")
	$i=0
		while true
		if $inst[$i] == nil
		return
		end
		@@stdin.write("#{$inst[$i]+"\n"}")
                puts "(gdb) #{$inst[$i] }"
		$i += 1
		@@buf=""
			while true
				read_write()
	
				if @@ch != nil
				@@buf= @@buf + @@ch
				end

				if (@@buf.include? "(gdb) ") or @@buf==""
					@@buf = @@buf.slice(0,@@buf.length-6)
					break
				end
			end
					if @@buf != ""	
					puts @@buf
					end
			if $i == $inst.length
				break			
				end
		
				
		end
	end

	def preproc cmd
		if cmd.strip == "loadsession"
		system("cd #{$foldername} ; ls -l *.gdb ; cd ..")
			while true
			print"Enter session name "
			$sessionname = gets
			$sessionname = $sessionname.slice(0,$sessionname.length-1)
				if ! File.exist?("./#{$foldername}/#{$sessionname}.gdb")
					puts "session does not exist"
					else
					load()
					break
				end
			end
		end

		if cmd.strip == "storesession"
			while true
			print"Enter session name to store : "
			$sessionname = gets
			$sessionname = $sessionname.slice(0,$sessionname.length-1)
				if File.exist?("./#{$foldername}/#{$sessionname}.gdb")
					print "session exist by this name already "
					else
					$file.close
					#system("cp temp.gdb #{$sessionname}.gdb")
					#filetp1 = File.open("temp.gdb","r")
					#filetp2 = File.open("./#{$foldername}/#{$sessionname}.gdb","w")
					#puts filetp1.read
					#filetp2.print(filetp1.read)
					system("cat ./temp.gdb > ./#{$foldername}/#{$sessionname}.gdb")
					break
				end
			end
		end

	end
	
	def execute
		while true
			print "(gdb) "
			cmd = gets
			temp = cmd.slice(0,cmd.length-1)
				if $command.include? temp
					preproc(temp)
					else
					if !cmd.include? "exit"
					$file.print(cmd)
					end
						if cmd.delete("\n")=="exit"
						break
						end
					@@stdin.write(cmd)
					@@buf=""
						while true
							read()
	
							if @@ch != nil
								@@buf= @@buf + @@ch
							end

							if (@@buf.include? "(gdb) ") or @@buf==""
								@@buf = @@buf.slice(0,@@buf.length-6)
								break
							end
						end
						if @@buf != ""	
							puts @@buf
						end
				end
		end	
	end
end

gdb = Gdbconsole.new
gdb.start()
gdb.execute()
