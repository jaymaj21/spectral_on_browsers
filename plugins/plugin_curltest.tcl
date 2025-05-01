userproc abort_curl_tests {} {
    global should_abort_curl_tests;
    set should_abort_curl_tests 1;
}

userproc init_abort_curl_tests {} {
    global should_abort_curl_tests;
    set should_abort_curl_tests 0;
}
init_abort_curl_tests;

userproc find_in_folder_or_parents {folder find_file_name} {
    set fname "${folder}/${find_file_name}"
    if {[file exists $fname]} {
        return $fname;
    }
    regsub -all {/[^/]*$} $folder {} parent_folder;
    if {$folder != $parent_folder} {
        return [find_in_folder_or_parents $parent_folder $find_file_name];
    } else {
        return "";
    }
}

set curltest_runCount 0;
set curltest_failCount 0;

userproc reindent_json_file {fname} {
    if {[catch {exec python -m json.tool $fname > $fname.tmp} msg]} {
        addToStatus $msg;
    }
    file copy -force ${fname}.tmp $fname;
    file delete -force ${fname}.tmp;
    
}
userproc curltest {filename {lnum ""}} {
    global curltest_runCount;
    global curltest_failCount;
    global should_abort_curl_tests;
    set default_url "http://localhost:9990";
    set default_endpoint "/api/servicestatus";

    set folder [regsub -all {/[^/]*$} $filename ""];
    set filebase [regsub -all {\.[^.]*$} $filename ""];
    

    set url $default_url;
    set urlfile [find_in_folder_or_parents $folder "url.txt"];
    if {$urlfile != ""} {
        set url [string trim [read_file_contents $urlfile]];
    }
    
    set endpoint $default_endpoint;
    set endpointfile [find_in_folder_or_parents $folder "endpoint.txt"];
    if {$endpointfile != ""} {
        set endpoint [string trim [read_file_contents $endpointfile]];
    }

    set hostname $url;
    regsub -all {https?://([^/:]+)[:/]?} $hostname {\1} hostname;
    addToStatus "looking for token file ${hostname}.token";
    set tokenfile [find_in_folder_or_parents $folder "${hostname}.token"];
    if {$tokenfile != "" } { addToStatus "tokenfile=$tokenfile " }
    set access_token "";

    if {$tokenfile != ""} {
        set access_token [string trim [read_file_contents $tokenfile]];
    }
    set request [string trim [read_file_contents $filename]];
    
    
    update;
    set tt [time {
        if {$access_token == ""} {
            if {$request == ""} {           
                addToStatus "curl --request GET -s -d @${filename} -H \"Content-Type: application/json\" ${url}${endpoint}" ;
                catch {exec curl --request GET -s -d "@${filename}" -H "Content-Type: application/json" "${url}${endpoint}" >    ${filebase}.out} msg;
            } else {
                addToStatus "curl -s -d @${filename} -H \"Content-Type: application/json\" ${url}${endpoint}" ;
                catch {exec curl -s -d "@${filename}" -H "Content-Type: application/json" "${url}${endpoint}" >    ${filebase}.out} msg;                
            }
        } else {
            if {$request == ""} {     
                addToStatus "curl --request GET --insecure -s -d @${filename} --oauth2-bearer $access_token -H \"Content-Type: application/json\" ${url}${endpoint}" ;
                catch {exec curl --request GET --insecure -s -d "@${filename}" --oauth2-bearer $access_token -H "Content-Type: application/json" "${url}${endpoint}" > ${filebase}.out} msg;
            } else {
                addToStatus "curl --insecure -s -d @${filename} --oauth2-bearer $access_token -H \"Content-Type: application/json\" ${url}${endpoint}" ;
                catch {exec curl --insecure -s -d "@${filename}" --oauth2-bearer $access_token -H "Content-Type: application/json" "${url}${endpoint}" > ${filebase}.out} msg;
                
            }
        }
    if {$msg != ""} {
        addToStatus $msg;
    }
   }];
   
   set outcont [string trim [read_file_contents ${filebase}.out]];
   
   file copy -force ${filebase}.out ${filebase}.rawout;

   set firstchar [string index $outcont 0];
   if { $firstchar == "\{" || $firstchar == "\[" } {
      reindent_json_file ${filebase}.out;
   }

   update;
   if {$lnum != "" } {
       set linestart "${lnum}.0";
       set lineend [[editor] index "${lnum}.0 lineend"];
   }

   if {![file exists "${filebase}.golden"]} {
     file copy -force "${filebase}.out" "${filebase}.golden";
     addToStatus "$filename CREATING GOLDEN OUTPUT";
     if {$lnum != ""} {
         [editor] tag remove #aafba2 $linestart $lineend;
         [editor] tag remove #fd9f9f $linestart $lineend;
         [editor] tag add #f0f583 $linestart $lineend;
     }
   } else {
    catch {exec diff "${filebase}.golden" "${filebase}.out" > ${filebase}.diff} msg;
    if {$msg != ""} {
        addToStatus $msg;
    }
    
    set fpdiff [open "${filebase}.diff" r];
    set diffcont [string trim [read $fpdiff]];
    close $fpdiff;
    if {$diffcont != ""} {
        if {$lnum != ""} {
         [editor] tag remove #aafba2 $linestart $lineend;
         [editor] tag remove #f0f583 $linestart $lineend;
         [editor] tag add #fd9f9f $linestart $lineend;
        }
        incr curltest_failCount;
        addToStatus "$filename FAILED : $tt";
    } else {
        if {$lnum != ""} {
         [editor] tag remove #fd9f9f $linestart $lineend;
         [editor] tag remove #f0f583 $linestart $lineend;
         [editor] tag add #aafba2 $linestart $lineend;
        }
        addToStatus "$filename PASS : $tt";
    }
  }
  incr curltest_runCount;
}

userproc rebaseline_curl_tests {} {
    global should_abort_curl_tests;
    set fulltext [[editor] get 1.0 end];
    set lines [split $fulltext "\n"];
    set cnt 0;
    foreach line $lines {
        if {$should_abort_curl_tests} {
            set should_abort_curl_tests 0;
            break;
        }
        incr cnt;
        set line [string trim $line];
        if {$line == "" || [string range $line 0 0] == "#"} {
            continue;
        }
        set filebase [regsub -all {.[^.]*$} $line ""];
        catch {
            file copy -force ${filebase}.golden ${filebase}.out;
       } msg;
       addToStatus $msg;
   }
   tk_messageBox -message "Finished rebaselining";
}

userproc generaltest {filename {lnum ""}} {
    global curltest_runCount;
    global curltest_failCount;
    global should_abort_curl_tests;
    set default_executable "bash";
    set default_preamble "";
    set default_args {};

    set folder [regsub -all {/[^/]*$} $filename ""];
    set filebase [regsub -all {\.[^.]*$} $filename ""];
    

    set executable $default_executable;
    set execfile [find_in_folder_or_parents $folder "executable.txt"];
    if {$execfile != ""} {
        set executable [string trim [read_file_contents $execfile]];
    }
    
    set args $default_args;
    set argsfile [find_in_folder_or_parents $folder "args.txt"];
    if {$argsfile != ""} {
        set args [string trim [read_file_contents $argsfile]];
    }
    
    set preamble $default_preamble;
    set preamblefile [find_in_folder_or_parents $folder "preamble.txt"];
    if {$preamblefile != ""} {
        set preamble [string trim [read_file_contents $preamblefile]];
    }
    
    set fptmp [file tempfile tmpfilename];
    puts $fptmp $preamble;
    set testfilecontent [read_file_contents $filename];
    puts $fptmp $testfilecontent;
    close $fptmp;
    
    update;
    set tt [time {
        addToStatus "exec $executable $args $tmpfilename" ;
        catch {exec $executable {*}$args $tmpfilename >    ${filebase}.out} msg;    
    if {$msg != ""} {
        addToStatus $msg;
    }
   }];
  

   update;
   if {$lnum != "" } {
       set linestart "${lnum}.0";
       set lineend [[editor] index "${lnum}.0 lineend"];
   }

   if {![file exists "${filebase}.golden"]} {
     file copy -force "${filebase}.out" "${filebase}.golden";
     addToStatus "$filename CREATING GOLDEN OUTPUT";
     if {$lnum != ""} {
         [editor] tag remove #aafba2 $linestart $lineend;
         [editor] tag remove #fd9f9f $linestart $lineend;
         [editor] tag add #f0f583 $linestart $lineend;
     }
   } else {
    catch {exec diff "${filebase}.golden" "${filebase}.out"  > ${filebase}.diff} msg;
    if {$msg != ""} {
        addToStatus $msg;
    }
    
    set fpdiff [open "${filebase}.diff" r];
    set diffcont [string trim [read $fpdiff]];
    close $fpdiff;
    if {$diffcont != ""} {
        if {$lnum != ""} {
         [editor] tag remove #aafba2 $linestart $lineend;
         [editor] tag remove #f0f583 $linestart $lineend;
         [editor] tag add #fd9f9f $linestart $lineend;
        }
        incr curltest_failCount;
        addToStatus "$filename FAILED : $tt";
    } else {
        if {$lnum != ""} {
         [editor] tag remove #fd9f9f $linestart $lineend;
         [editor] tag remove #f0f583 $linestart $lineend;
         [editor] tag add #aafba2 $linestart $lineend;
        }
        addToStatus "$filename PASS : $tt";
    }
  }
  file delete -force $tmpfilename;
  incr curltest_runCount;
}

userproc run_test_suite {{cmd curltest}} {
    global should_abort_curl_tests;
    global curltest_runCount;
    global curltest_failCount;
    set curltest_runCount 0;
    set curltest_failCount 0;
    set fulltext [[editor] get 1.0 end];
    set lines [split $fulltext "\n"];
    set cnt 0;
    foreach line $lines {
        if {$should_abort_curl_tests} {
            set should_abort_curl_tests 0;
            break;
        }
        incr cnt;
        set line [string trim $line];
        if {$line == "" || [string range $line 0 0] == "#"} {
            continue;
        }
        set filename $line;
        set filebase [regsub -all {\.[^.]*$} $line ""];
        catch {
          $cmd $filename  $cnt
       } msg;
       addToStatus $msg;
   }
   tk_messageBox -message "Finished : Ran $curltest_runCount tests, $curltest_failCount failed";
}
