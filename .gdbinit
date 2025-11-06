set history save on
set history size 10000
set history filename ~/.gdb_history

# Print backtrace of all threads
define btall
thread apply all backtrace
end

macro define offsetof(t, f) &((t *) 0)->f



# mostly taken from https://interrupt.memfault.com/blog/advanced-gdb#essentials
# check this out https://interrupt.memfault.com/blog/automate-debugging-with-gdb-python-api 
# for some python configuration of gdb
#
## basics you already probably know
#
# print
# break
# watch
# bt
# run
# help info
#
## some maybe useful commands
#
# list
# set listsize 20
# 
# tui enable
#
# info locals // prints local variables
# info args
# info variables // prints everything
# info variables coredump* // can find reg ex variables
# info variables -t int // varialble type
# info func?
# 
# referece variavles from specific files
# p &'mempool.c'::lock
#     $4 = (struct k_spinlock *) 0x20002370 <lock>
# 
#
# show values // prints values which have been previously called 
#
# set $test = 5 // make a variable called test
# p $test
#     $4 = 5
#
#
## dumb for loop
# (gdb) set $i = 0
# (gdb) print shell_wifi_commands[$i++]->help
# $1 = 0x80314e0 "\"<SSID>\"\n<SSID length>\n<channel number (optional), 0 means all>\n<PSK (optional: valid only for secured SSIDs)>"
# (gdb) <enter>
# $2 = 0x803155c "Disconnect from Wifi AP"
#
## '$' variable
# (gdb) p "hello"
# $63 = "hello"
# (gdb) p $
# $64 = "hello"
#
#
#  Thinking now i guess it would be good to know how the main file delcares everything
#  or just know how to get in a 'local' scope everytime 
#
## conditional breaking 
# You don’t exactly know when or how a num_samples argument is being corrupted
# with the value of 0xdeadbeef when the function compute_fft is called. We can improve
# our investigation using conditional breakpoints.
#
# (gdb) break compute_fft if num_samples == 0xdeadbeef
#
## also with watch
#
# (gdb) watch i if i == 100
# 
# (gdb) info watchpoints
# Num     Type           Disp Enb Address    What
# 1       hw watchpoint  keep y              i stop only if i == 100
#
#
## This macro can also be placed directly within a .gdbinit file.
# With this in place, we can now print the offset of any struct members.
# (gdb) p/d offsetof(struct k_thread, next_thread)
# $3 = 100
#
## you can call make to trigger normal shell make in the couurrent dir
## also can run 'shell <my commands>' to call shell stuff
#
# set logging on // to output logs to text files
#
## some more on variable access
#
#     class BST {
#         BST()
#         ...
#         private:
#         int add((BST * root, BST *src);
#     }
#
# (gdb) break 'BST::add(<TAB>
# (gdb) break 'BST::add(BST*, BST*)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# 
