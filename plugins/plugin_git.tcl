userproc git_stage {} {
 set pwd [pwd];
 cd [get_current_folder];
 catch {
  set fname [get_current_filename];
  regsub -all {^.*/([^/]*)} $fname {\1} fname;
  exec git stage $fname --force;
 } msg;
 puts $msg;
 cd $pwd;
};

set gitmenu [addmenu [getmenu] git "Git"];
addmenucommand $gitmenu "Git Stage" git_stage;

