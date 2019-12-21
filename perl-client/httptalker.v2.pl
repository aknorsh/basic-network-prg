#!/usr/bin/perl -w

# $Id: http-client.pl.v 1.3 2003/03/23 11:28:03 68user Exp $
# -> aknorsh

use strict;
use Socket;

### Util ####################

sub showUsage {
  print "httptalker -- simple HTTP client\n";
  print "USAGE: httptalker -METHOD URL [PROXY]\n";
  print "       -METHOD: Get/Head\n";
  exit;
}

### PARSE ARGS ####################

my $method;
my $host;
my $port;

# show usage if args are invalid
if ($#ARGV < 1) {
  &showUsage();
}

# parse method
if ($ARGV[0] eq '-GET' || $ARGV[0] eq '-get') {
  $method = 'GET';
} elsif ($ARGV[0] eq '-HEAD' || $ARGV[0] eq '-head') {
  $method = 'HEAD';
} else {
  &showUsage();
}

$host = $ARGV[1];
$port = getservbyname('http', 'tcp');

### MAKE REQUEST ####################

my $iaddr = inet_aton($host)
  or die "There is no host named :$host \n";

# Make Socket
my $sock_addr = pack_sockaddr_in($port, $iaddr);
socket(SOCKET, PF_INET, SOCK_STREAM, 0)
  or die "Cannot create socket.\n";


# Connect
connect(SOCKET, $sock_addr)
  or die "Cannot connect to $host : $port.\n";
# Disable buffering
select(SOCKET); $|=1; select(STDOUT);


# Send request
print SOCKET $method . " /index.html HTTP/1.0\r\n";
print SOCKET "User-Agent: httptalker/0.10 (HTTP client sample)\r\n";
print SOCKET "\r\n";


### DISPLAY RESPONSE ####################

if ($method eq 'GET') {
  while (<SOCKET>) {
    m/^\r\n$/ and last;
  }
  while (<SOCKET>) {
    print $_;
  }
} elsif ($method eq 'HEAD') {
  while (<SOCKET>) {
    print $_;
    m/^\r\n$/ and last;
  }
}
