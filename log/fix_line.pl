#!/usr/bin/perl -w   
  
  
  
while(<>)  
{  
  
chomp($_);  
if($_ =~ m/(Query|Connect)/g){  
  
    print "\n",$_;  
    next;  
  
  
}elsif($_ =~ m/^\s*$/g){  
  
    next;  
  
}else{  
        $_ =~ s/^\s+|\s+$//g;  
    print " ",$_;  
  
}  
  
  
}
