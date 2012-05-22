@    14400   IN      SOA     ns0.main. root.base.%dom%. (
      1075314055    ; serial, todays date+todays
      28800           ; refresh, seconds
      7200            ; retry, seconds
      3600000         ; expire, seconds
      86400 )         ; minimum, seconds

@ 14400 IN NS ns0.main.
@ 14400 IN NS ns1.main.
@ 14400 IN A %ip%

@ 14400 IN MX 0 mail
@ 14400 IN TXT "v=spf1 a mx ~all"

mail    14400           IN      A        %ip%
www     14400           IN      CNAME    @
*       14400           IN      CNAME    @


