#------------------------------------------------------------------
# latexmk Configuration File
#------------------------------------------------------------------

#------------------------------------------------------------------
# Engine and Compiler Options
#------------------------------------------------------------------
$pdf_engine = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error';

#------------------------------------------------------------------
# Output Directories
#------------------------------------------------------------------
$out_dir = 'out';
$aux_dir = 'out';
$latex = 'platex -synctex=1 -halt-on-error -interaction=nonstopmode';
#------------------------------------------------------------------
# Automatic Cleanup
#------------------------------------------------------------------
# Set to 1 to clean up generated files after a successful build.
$do_cleanup = 1;

# Set to 1 to clean up files when exiting PVC (continuous preview) mode.
$pvc_do_cleanup = 1;

# --- ADD THIS LINE ---
# Explicitly list all auxiliary file extensions to be removed.
# This ensures that files from packages like Beamer (.nav, .snm) are also deleted.
$clean_ext = 'aux fdb_latexmk fls log nav out snm toc';
# --- END OF ADDED LINE ---

#------------------------------------------------------------------
# Viewer Settings (Optional)
#------------------------------------------------------------------
$new_viewer_always = 0;
