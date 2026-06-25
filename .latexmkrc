# latexmk Configuration File
#------------------------------------------------------------------

#------------------------------------------------------------------
# Engine and Compiler Options
#------------------------------------------------------------------
# lualatex を使う（jlreq + luatexja）。
# 注意: $pdf_engine は latexmk の変数ではなく無効。正しくは $pdf_mode + $lualatex。
$pdf_mode = 4; # 1=pdflatex, 3=dvipdfmx, 4=lualatex, 5=xelatex
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$bibtex = 'upbibtex';
#------------------------------------------------------------------
# Output Directories
#------------------------------------------------------------------
$out_dir = 'out';
$aux_dir = 'out';
# $latex = 'platex -synctex=1 -halt-on-error -interaction=nonstopmode';

#------------------------------------------------------------------
# Automatic Cleanup
#------------------------------------------------------------------
# Set to 1 to clean up generated files after a successful build.
$do_cleanup = 1;

# Set to 1 to clean up files when exiting PVC (continuous preview) mode.
$pvc_do_cleanup = 1;

# Allow cleanup in the output directory.
$cleanup_includes_outdir = 1;

# Explicitly list all auxiliary file extensions to be removed.
# This ensures that files from packages like Beamer (.nav, .snm) are also deleted.
# Added more extensions to clean up most intermediate files.
$clean_ext = 'aux bbl bcf blg fdb_latexmk fls log nav out run.xml snm synctex.gz toc vrb ';

#------------------------------------------------------------------
# Viewer Settings (Optional)
#------------------------------------------------------------------
$new_viewer_always = 0;
