#/usr/bin/perl -w 

####################################
###author: fangqi@baidu.com  #######
###20141110
####################################

use Getopt::Long;

my $ways={
   general => \&get_time_from_general,
   slow    => \&get_time_from_slow,
   slave   => \&get_time_from_slave,
   innodb  => \&get_time_from_innodb,
};

GetOptions(
      'log=s' =>  \$logtype, 
        );

&print_help  unless defined $logtype;
&print_help  unless ($logtype=~/innodb|slave|slow|general/g);

my $time='';

while(<>){
   chomp;
   my $tmp_time= $ways->{$logtype}->($_);
   $time=$tmp_time?$tmp_time:$time;
   print "[$time] $_\n"
}




sub get_time_from_general()
{
     my ($sql) = @_;
      my $time=0;
       if ($sql =~/(\d{6} [\d\s]\d:\d\d:\d\d)/g){
             $time=$1; 
              }
        return $time;
}

sub get_time_from_innodb()
{
     my ($sql) = @_;
     my $time=0;
     if ($sql =~/(14\d+\s+\d+:\d+:\d+)\s+INNODB MONITOR OUTPUT/g){
     $time=$1; 
     }       
     return $time;
}

sub get_time_from_slow()
{
my ($sql) = @_;
my $time=0;
if ($sql =~/^# Time: (\d{6}\s+\d+:\d+:\d+)/g){
    $time=$1;  
    }
    return $time;
}

sub get_time_from_slave()
{
my ($sql) = @_;
my $time=0;
if ($sql =~/[\-]{1,}(\d{8}\s+\d+:\d+:\d+)/g){
        $time=$1;
    }
    return $time;
}

sub print_help()
{
print <<EOF;
userage: perl ds-log-time.pl  --log=[slow|general|slave|innodb] logfile
EOF

exit;
}
