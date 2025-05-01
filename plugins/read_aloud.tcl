package require Tk
package require twapi


set dir [lindex $argv 0];
cd $dir;
wm iconbitmap . -default $dir/bm0.ico
wm  overrideredirect  .  1
wm attributes . -topmost 1;
wm  geometry  .  "+100+100"


set fname [lindex $argv 1];
set fp [open $fname r];
set textToRead [read $fp];
close $fp;

set voice [twapi::comobj Sapi.SpVoice]
$voice Speak $textToRead 1

button .b -text "Close Reader" -command {
    catch {
    $voice -destroy;
    }
    exit;

} -background blue

pack .b -side top -fill x;
update;

update;
