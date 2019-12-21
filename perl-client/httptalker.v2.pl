#!/usr/bin/perl -w

# $Id: http-client.pl.v 1.3 2003/03/23 11:28:03 68user Exp $
# -> aknorsh

use strict;
use Socket;

### PARSE ARGS ####################

my $method;
my $connect_host;
my $host;
my $path;
my $port;
my $proxy = '';

if ($#ARGV < 1) {
  print "httptalker -- simple HTTP client\n";
  print "USAGE: httptalker -METHOD URL [PROXY]\n";
  print "       -METHOD: Get/Head\n";
  exit;
}

# method
if ($ARGV[0] eq '-GET' || $ARGV[0] eq '-get') {
  $method = 'GET';
} elsif ($ARGV[0] eq '-HEAD' || $ARGV[0] eq '-head') {
  $method = 'HEAD';
} else {
  print "Invalid args.\n";
}

# URL
if ($ARGV[1] =~ m|^http://([-_/.a-zA-Z0-9]+)/?(.*)$| ) {
  $host = $1;
  $path = $2;
} else {
  print "Invalid URL.\n";
}

if ($#ARGV == 2) {
# Proxy
  if ($ARGV[2] =~ m|^([-_/.a-zA-Z0-9]+):(\d+)$| ) {
    $proxy = $1;
    $port = $2;
  } else {
    print "Invalid proxy.\n";
  }
  $connect_host = $proxy;
} else {
  $connect_host = $host;
   $port = getservbyname('http', 'tcp');
}

### CONNECTION  ####################

# Get ip
my $iaddr = inet_aton($connect_host)
  or die "There is no host named '$connect_host'\n";

# Make Socket
my $sock_addr = pack_sockaddr_in($port, $iaddr);

socket(SOCKET, PF_INET, SOCK_STREAM, 0)
  or die "Cannot create socket.\n";

connect(SOCKET, $sock_addr)
  or die "Cannot connect to $connect_host:$port.\n";

# Disable buffering
select(SOCKET); $|=1; select(STDOUT);


### send REQUEST  ####################

if ($proxy eq '') {
  print SOCKET "$method http://$host/$path HTTP/1.0\r\n";
}
else {
  print SOCKET "$method /$path HTTP/1.0\r\n";
}

print SOCKET "User-Agent: httptalker/0.10 (HTTP client sample)\r\n";
print SOCKET "\r\n";


### receive RESPONSE ####################

if ($method eq "GET") {
  while (<SOCKET>) {
    m/^\r\n$/ and last;
  }
  while (<SOCKET>) {
    print $_;
  }
} elsif ($method eq "HEAD") {
  while (<SOCKET>) {
    print $_;
    m/^\r\n$/ and last;
  }
}
