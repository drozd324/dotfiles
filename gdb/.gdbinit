set history save on
set history size 10000
set history filename ~/.gdb_history
set listsize 20
set confirm off
set print pretty on

#set logging on # will print output into a text file in local dir 
# might be useful to use in conjunction with another terminal opened
# side by side
#set logging off

#py
#class GrepCmd (gdb.Command):
#    """Execute command, but only show lines matching the pattern
#    Usage: grep_cmd <cmd> <pattern> """
#
#    def __init__ (_):
#        super ().__init__ ("grep_cmd", gdb.COMMAND_STATUS)
#
#    def invoke (_, args_raw, __):
#        args = gdb.string_to_argv(args_raw)
#        if len(args) != 2:
#            print("Wrong parameters number. Usage: grep_cmd <cmd> <pattern>")
#        else:
#            for line in gdb.execute(args[0], to_string=True).splitlines():
#                if args[1] in line:
#                    print(line)
#
#GrepCmd() # required to get it registered
#end

# Print backtrace of all threads
define btall
thread apply all backtrace
end

macro define offsetof(t, f) &((t *) 0)->f

########################################################################
#
# mostly taken from https://interrupt.memfault.com/blog/advanced-gdb#essentials
# check this out https://interrupt.memfault.com/blog/automate-debugging-with-gdb-python-api 
# for some python configuration of gdb
# also do use some llm for some helpful nudging
#
################# basics you should probably know #################
#
# print
# break # info breakpoints
# watch # info watchpoints
# bt
# run
# help info
# where
# info locals
# info sources // actually shows fils used to make everything 
# info functions
# info functions MyClass // for functions in a class
#
#
## good keep in mind it looks like all agruments that prompts take are or can be  
# assumened to be in regular expression 
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
# info files / info target
# 
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
## printing classes and class members us c styly syntax
# (gdb) p this
# $1 = (Delaunay * const) 0x7fffffffd9d0
# (gdb) p (Delaunay * const) 0x7fffffffd9d0
# $2 = (Delaunay * const) 0x7fffffffd9d0
# (gdb) p *((Delaunay * const) 0x7fffffffd9d0)
# 
## some llm workflow guide  
# (gdb) break main
# (gdb) run
# (gdb) print &delaunay.nTri
# $1 = (int *) 0x55555576b4f0
# (gdb) watch *(int*)0x55555576b4f0
# Hardware watchpoint 1: *(int*)0x55555576b4f0
# (gdb) continue
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
