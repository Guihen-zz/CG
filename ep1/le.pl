use LWP::Simple qw( get);

$url = 'http://bridgesaopaulo.com.br/magic2011/cpel2014.htm';
$webpage = get($url);
@fragment = split m|<pre>|si, $webpage;
@fragment = split m|</pre>|si, $fragment[1];
@infos = split m|-------------------------------------------------------------------------------------------------------------|s, $fragment[0];

@temp = split m|\n|, @infos[0];
$resumo = "<table>";
foreach( @temp)
{
  if( $_ =~ m|\s+(\d+)\s+(\d+)\s+(\d+[,]?\d*)\s+(\S+)\s+(.+)|)
  {
    $resumo .= "<tr><td>$1</td><td>$2</td><td>$3</td><td>$4</td><td>$5</td></tr>";
  }
}
$resumo .= "</table>";

$parsed = "";
$index = 1;
foreach( @infos)
{
  if( $_ =~ m|Round:  (\d+)|)
  {
    $parsed .= '<div class="result-box" id="result' . $index++ . '" />';
    $parsed .= '<table class="resultado" >';
    undef($thead);
    @lines = split m|\n|, $_;
    for( $i = 4; $i <= 10; $i++)
    {
      @content = split m|\s+|, $lines[$i];
      $size = @content;
      if( !defined( $thead))
      {
        $parsed .= "<thead><tr class=\"titulo\"><th colspan=\"$size\">Round: $1</tr></thead>";
        $thead = '<thead class="preto"><tr>';
        $thead .= q|<th id="tbl">Tbl</th>
                    <th id="team">Team</th>
                    <th></th>
                    <th></th>
                    <th></th>|;
        if( $size > 6)
        {
          $thead .= q|<th id="1">1</th>
                      <th id="2">2</th>
                      <th id="imp">IMP</th>
                      <th >+/-</th>
                      <th id="score" colspan="2">Score</th>|;
        }
        $thead .= "</tr></thead>";
        $parsed .= $thead;
      }

      $color = ($i % 2 == 0) ? "claro" : "escuro";
      $parsed .= "<tr class=\"$color\">";
      # content[0] is a blank content.
      $parsed .= "<td>$content[1]</td>
                  <td>$content[2]</td>
                  <td>$content[3]</td>
                  <td>$content[4]</td>
                  <td>$content[5]</td>";
      if( $size > 6)
      {
        $parsed .= "<td>$content[6]</td>
                    <td>$content[7]</td>
                    <td>$content[8]</td>";
        if( $size == 11)
        {
          $parsed .= "<td></td>
                      <td>$content[9]</td>
                      <td>$content[10]</td>";
        }
        else
        {
          $parsed .= "<td>$content[9]</td>
                      <td>$content[10]</td>
                      <td>$content[11]</td>"; 
        }
      }
      $parsed .= "</tr>";
    }
    $parsed .= '</table>';
    $parsed .= '</div>';
  }
}

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mes = $mon + 1;
$ano = $year + 1900;
$relogio = sprintf( "%02d:%02d:%02d (%02d/%02d/%04d)", $hour, $min, $sec, $mday, $mes, $ano);
open ($fh, "template.html");
my @outFile = <$fh>;
foreach (@outFile)
{
    $_ =~ s/{RESUMO}/$resumo/g;
    $_ =~ s/{INFO}/$parsed/g;
    $_ =~ s/{CONTADOR}/$index/g;
    $_ =~ s/{RELOGIO}/$relogio/g;
}

my $file;
open ($file, ">result.html");
print $file @outFile;

close $file;
close $fh;