**i4 kmod -- Start and stop**  
$ insmod i4kmod.ko  
$ lsmod | grep i4  
$ rmmod i4kmod  

**i4kmod -- Deploy and use**  
$ mount /dev/sdb /i4  
$ touch /i4/.i4  
$ insmod i4kmod.ko  
$ ./i4ctl -m /i4/.i4  
$ echo asdfasdfadsfadsfasd > /i4/test.txt  
$ ls /i4  
$ cp /i4/test.txt /tmp  >>> will deny exfil "Bad file descriptor"
$ cp /i4/test.txt /i4/test.txt.bak   >>> will be allowed, still within protected /i4 dir

** delivery **
locate all bare metal server files  ---
/usr/sbin/i4
