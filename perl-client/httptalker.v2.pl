#!/usr/bin/perl -w

# $Id: http-client.pl.v 1.3 2003/03/23 11:28:03 68user Exp $
# -> aknorsh

use strict;
use Socket;

if ($#ARGV < 1) {
  print "httptalker -- simple HTTP client\n";
  print "USAGE: httptalker -METHOD URL [PROXY]\n";
  print "       -METHOD: Get/Head\n";
  exit;
}

# Make host:port
my $host = $ARGV[0];
my $port = getservbyname('http', 'tcp');

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
print SOCKET "GET /index.html HTTP/1.0\r\n";
print SOCKET "User-Agent: httptalker/0.10 (HTTP client sample)";
print SOCKET "\r\n";


# Recieve response
# Skip header
while (<SOCKET>) {
  m/^\r\n$/ and last;
}
# Display body
while (<SOCKET>) {
  print $_;
}
