# add_cus_dep( 'glo', 'gls', 0, 'glo2gls' );
# # add_cus_dep( 'acn', 'acr', 0, 'glo2gls');  # from Overleaf v1
# sub glo2gls {
#     system("makeglossaries $_[0]");
# }

# $pdf_previewer = 'open %S';

##
## GLO to GLS conversion hook
##
# add_cus_dep( 'slo', 'sls', 0, 'makeglossaries' );
# add_cus_dep( 'acn', 'acr', 0, 'makeglossaries' );
# add_cus_dep( 'glo', 'gls', 0, 'makeglossaries' );
# $clean_ext .= "slo sls slg acr acn alg glo gls glg";
# sub makeglossaries {
#    my ($base_name, $path) = fileparse( $_[0] );
#    pushd $path;
#    my $return = system "makeglossaries", $base_name;
#    popd;
#    return $return;
# }

##
## To enable shell-escape for all *latex commands
##   Used i.e. for svg package invoking inkscape
##
set_tex_cmds( '--shell-escape %O %S' );

## Set default TeX file
@default_files = ('main.tex');

##
## Latexmk build properties
##
$pdf_mode = 1;
$postscript_mode = $dvi_mode = 0;
$bibtex_use = 1;

##
## Build directory
##
# $out_dir = '_build';
