This is to build a web server on an EC2 instance in the style of the old Quintessential Business Solutions
servers to transition off of old Virtual Machines and Co-Los, you probably don't care about this.


To build a new server:

./run.sh


This was really just written for me but I don't care if you look at it if you aren't me,
I don't even care if you use it but I make no promises that it would do what you want if
you aren't me.

If you are me and you forgot you wrote this then hello me it's me again.


Built from command line on a Mac with:

    git version 2.14.1
    GNU bash, version 5.0.7(1)-release
    Docker version 19.03.8, build afacb8b

assumptions at the time of this writing (I'll probably forget to update this file):
	1) your .aws credentials are in /root/.aws
	2) you have a pem in /root/.ssh/ named qbsweb1.pem that matches a keypair named qbswebserver










