use IO::Socket::INET;
use JSON;
use Data::Dumper qw(Dumper);

$nick = 'perldoc';
# auto-flush on socket
$| = 1;
my $bold = chr(8);
 
# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => '100.100.151.181', #
    PeerPort => '3456',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";
#{"event":"msg","time":1477497743.94675,"v":1,"data":{"from":"112Nick","to":"#all","text":"perldoc perldoc"}}
# data to send to a server
#my $req = 'hello world';
#my $size = $socket->send($req);
#{"event":"join","data":{"to":"#all","nick":"hdjthfjh"},"time":1477498402.13339,"v":1}

#print "sent data of length $size\n";
$t = time;
#$socket->recv($response, 1024);
$auth = '{"cmd":"nick","data":{"nick":"'.$nick.'","time":'.$t.'},"v":1}'."\n";
$size = $socket->send($auth);
# notify server that request has been sent
#shutdown($socket, 1);
 
# receive a response of up to 1024 characters from server
while (1){
	my $response = "";
	$socket->recv($response1, 1024);
	print "received response: $response1\n\n";
	my @lines = split /\n/, $response1;
	$x = 0;
	while ($x< scalar @lines){
	$response = @lines[$x];
	$perl_hash_or_arrayref  = decode_json $response;
	print $perl_hash_or_arrayref -> {event} . " " . $perl_hash_or_arrayref -> {data} -> {text} ."\n";
	$t = time;
	if ($perl_hash_or_arrayref -> {event} == 'msg'){
		$res_nick = $perl_hash_or_arrayref -> {data} -> {from};
		print $res_nick . $res_nick . $res_nick ."1234567890\n"; 
		if ($perl_hash_or_arrayref -> {data} -> {text} eq "!who"){
			print $perl_hash_or_arrayref -> {data} -> {text} . "\n";
			#die();
			$cmd_output = "{\"cmd\":\"msg\",\"data\":{\"text\":\"I am $nick\"}, \"time\": $t, \"v\":1}\n";
			$size = $socket->send($cmd_output);
		} elsif ($perl_hash_or_arrayref -> {data} -> {text} =~ /^perldoc .*/){
			@cmd = $perl_hash_or_arrayref -> {data} -> {text} =~ /^perldoc (.*)/;
			print "OH MY GOD\n";
			#rce check
			print $cmd[0] ."\n";
			
			if ($cmd[0] !~ /^[\s0-9a-zA-Z\:_\-\n\r]*$/){
				print "NOOOO\n";
				#die();
			} else {
				my $cmd_output  = `perldoc -T $cmd[0] 2>&1`;
				$cmd_output =~ s/(.)$bold\1/$1/g;
				$cmd_output =~ s/[\cA-\cZ"\\]/ /g;
				
				@doc_out = $cmd_output =~ /NAME([\d\D]*)SYNOPSIS/s; 
				@desc_out = $cmd_output =~ /DESCRIPTION([\d\D]*)OPTIONS/s;
				print @desc_out[0];
				print "----".$doc_out[0]."----\n";
				if (scalar @doc_out){
					$cmd_output = "{\"cmd\":\"msg\",\"data\":{\"text\":\"$res_nick $doc_out[0]  $desc_out[0]\"}, \"time\": $t, \"v\":1}\n";
					$size = $socket->send($cmd_output );
				} else {
					$cmd_output = "{\"cmd\":\"msg\",\"data\":{\"text\":\"$res_nick $cmd_output\"}, \"time\": $t, \"v\":1}\n";
					$size = $socket->send($cmd_output );
				}
				$socket->recv($response, 1024);
				#{"cmd":"msg","data":{"text":"$cmd_output"}, "time": $t, "v":1}
				#print $cmd_output ."\n";
			}
		}
		
	}
	$x++;
	}
	
}
$socket->close();