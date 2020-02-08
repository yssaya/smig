#!/usr/bin/ruby
require 'io/console'
require 'timeout'
#require 'curses'
puts "Hello, world!"
puts `clear`

W=70
H=20

sec = 1  # interval
count = 0
draw_count = 0

L=900  # all history length, must be bigger than AVT2
array = []
array.fill(0, 0, L)
tmp_array = []
tmp_array.fill(0, 0, L)


AVT0 = 60
AVT1 = 300
AVT2 = 900

RED = "\e[31m"  # RED 31, BLUE 34, YELLOW 33
NC  = "\e[0m"

while
true

if count % 3600 == 0
  print `clear`
end
#ret = `echo "^[[1;1H"`
#print ret
print `tput cup 0 0`

r0 = `uptime`
pos = r0.index("load")
time = r0[1,8]
cpu  = r0[pos,99]

#t = `cat /proc/cpuinfo`
#tt = t.split("\n")[2]
#puts tt.split(" ")[3]
#puts r0.split(" ")[4]
#exit 0

#gpu=`nvidia-smi | awk 'NR==9' | awk '{print $13}'`
smi=`nvidia-smi`
smi_line = smi.split("\n")
gpu = smi_line[8].split(" ")[12]
tmp = smi_line[8].split(" ")[2]
#gpu= (rand(40) + 50).to_s + "%"
#tmp= (rand(20) + 30).to_s + "C"
ti=tmp.chop!.to_f
wi=gpu.chop!
w=wi.to_f

for i in 0..L-2
  array[i]=array[i+1]
  tmp_array[i]=tmp_array[i+1]
end
array[L-1]=w
tmp_array[L-1]=ti

s0 = 0
for i in L-AVT0..L-1
  s0 += array[i]
end
s1 = 0
for i in L-AVT1..L-1
  s1 += array[i]
end
s2 = 0
for i in L-AVT2..L-1
  s2 += array[i]
end

str = sprintf("%s    %s    GPU:%5.1f,%5.1f,%5.1f  sec=%d \n",time,cpu.chop! ,s0/AVT0, s1/AVT1, s2/AVT2, sec)

allstr = str

for h in 0..H
  str = ""
  for i in 0..W-1
    d0 = 0
    t0 = 0
    for j in 0..sec-1
#      d0 += 100 - array[L-W+i]
      d0 += 100 - array[L-(W-i)*sec+j]
      t0 += 100 - tmp_array[L-(W-i)*sec+j]
    end
    d=(d0 / sec) / 5
    t=(t0 / sec) / 5
    #echo "$h $i $d"
    if d.to_i == h.round
      if count+1 < (W-i)*sec
        str += "-"
      else  
        str += "*"
      end
    else
      if t.to_i == h.round
#        str += "."
        str += RED + "." + NC
      else 
        str += " "
      end
    end
  end

  d0= h * 5
  d1= 100 - d0
#  str += d1.to_s
  str += sprintf("%3d ",d1) #if (h%2) == 0 
  allstr += str
  allstr += "\n"
end

draw_count += 1
if draw_count >= sec
  puts allstr
  draw_count = 0
end

#c = STDIN.getch
#print c
#ch = STDIN.readbyte
#exit 0 if ch == 3 # CTRL+C

wait = 1
c = ""
begin
  status = Timeout::timeout(wait) {
#    printf "Input: "
    c = STDIN.getch
    exit 0 if c == "\C-c" || c=="q" || c=="Q" # CTRL+C
  }
# puts "Got: #{status}"
rescue Timeout::Error
# puts "Input timed out after #{sec} seconds"
end

if "1" <= c && c <= "9"
#  puts c
  sec = c.to_i
  draw_count = sec
end

count += 1

#sleep 1
end
