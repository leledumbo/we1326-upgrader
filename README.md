# WE1326 Upgrader
Programs to help downloading package updates for WE1326 router. With a little bit of creativity, it should be configurable for any devices.

# Compiling

The program is built with Free Pascal compiler, any version having HTTPS support (opensslsockets unit) will do. No special option required, just:

```bash
$ fpc generatepackagelinks.pas
$ fpc downloadupdates.pas
```

Of course you can add -CX -XXs -O4 if you like, but I won't bother doing it since it doesn't do any sophisticated algorithm nor it produces big executables.

# Running

First, run generatepackagelinks giving the firmware version whose packages you want to grab, redirecting the output to a file, e.g.:

```bash
$ ./generatepackagelinks 18.06.5 > package.links
```

For the time being, a little housekeeping is required as the first few lines will contain downloading logs. Stop when you find the first package=link.

Next, prepare a text file containing all packages whose updates you want to download, this can be easily done using `opkg list-installed | awk '{print $1}'`if you want to update everything.

Finally, run downloadupdates to get the package files with first parameter being the cleaned output from generatepackagelinks above and the second your package list:

```bash
$ ./downloadupdates package.links package.list
```

The packages will be downloaded to current directory. After this, you can use scp (or flashdisk if you prefer) to copy all the packages into your router and install them from there.

