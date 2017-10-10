#!perl

use strict;
use warnings;

use File::Find;
use Test::More;
use LedgerSMB::Sysconfig;
use Template;
use Template::Constants qw( :debug );
use WebService::Validator::HTML::W3C;

my @on_disk = ();

sub collect {
    my $module = $File::Find::name;
    return if $module !~ m/\.html$/
           || $module =~ m/\/pod\//
           || $module =~ m(/js/)
           || $module =~ m(/js-src/(dijit|dojo|util)/);

    push @on_disk, $module
}
find(\&collect, $ARGV[0] // 'UI/');

sub strip_pattern {
    my ($text,$pattern) = @_;
    while ( $text =~ /$pattern/ ) {
        my ($v1,$v2,$v3) = ($1,$2,$3);
        $v2 =~ s#[^\n]+##gs;
        $text = ($v1 // '') . ($v2 // '') . ($v3 // '');
    }
    return $text;
}

sub reportable_line {
    my ($p,$e,$line,$lines) = @_;
    return $p . ' at ' . $line . ' - ' .$e->msg
              . ($line ? (' in {{ ' . $lines->[$line] . ' }}')
                       : '');
}

sub content_test {
    my ($filename) = @_;
    my $ui_header_used = $filename =~ m/UI\/lib\//;
    my $is_snippet = $filename !~ m#(log(in|out))|main|setup/#
                  || $filename =~ m#setup/ui-db-credentials|'lib/ui-header#;

    my (@tab_lines, @trailing_space_lines);
    my $text = '';

    open my $fh, "<$filename";
    while (<$fh>) {
        push @tab_lines, ($.) if /\t/;
        push @trailing_space_lines, ($.) if / $/;
        $ui_header_used = 1 if /ui-header\.html/;
        $text .= $_;
        $is_snippet = 1
            if 1 == @tab_lines
            && $text =~ /HTML Snippet, for import only/
    }
    close $fh;
    warn "$filename, snippet: $is_snippet, ui-header: $ui_header_used";

    my %tt_config = (
        START_TAG => quotemeta('<?lsmb'),
        END_TAG => quotemeta('?>'),
        INCLUDE_PATH => ['templates/demo','UI/lib'],
        ENCODING => 'utf8',
        DELIMITER => ';',
        PRE_CHOMP => 1,
        POST_CHOMP => 1,
        TRIM => 1,
        INTERPOLATE => 1,
#        DEBUG => DEBUG_UNDEF | DEBUG_ON
    );
    my $vars = {
        dojo_theme => $LedgerSMB::Sysconfig::dojo_theme,
        dojo_built => $LedgerSMB::Sysconfig::dojo_built,
        dojo_location => $LedgerSMB::Sysconfig::dojo_location,
        USER => {
            id => 1,
            dateformat => 'yyyy-mm-dd'
        },
        SETTINGS => {
            default_currency => 'USD',
            decimal_places => 2
        }
    };
#use Data::Printer;
#warn p $filename;
    my $tt = Template->new(\%tt_config);
    my $tt_text;
    $tt->process(\$text,$vars,\$tt_text);
=x
    {
        #Do-while isn't a loop, thus the enclosing in {} so last can work.
        do {
            $tt->process(\$text,$vars,\$tt_text);
            if (!$tt_text) {
                my $error = $tt->error();
                #warn p $error;
                if ($error =~ /undef error - ([a-zA-Z0-9_\.]+) is undefined/) {
                    $vars->{$1} = "LSMB_$1";
                    #warn p $vars;
                }
                else {
                    last;
                }
            }
        } while !$tt_text;
    }
=cut
#    warn $tt->error() if !$tt_text;

=x
    $lint->load_plugin(WhiteList => +{
        rule => +{
            'attr-unknown' => sub {
                my $param = shift;
                return 1 if $param->{tag} =~ /input|div/ && $param->{attr} =~ /type|pwtype/;
                return 1 if $param->{tag} eq "textarea" && $param->{attr} eq "autocomplete";
                return 1 if $param->{tag} eq "div" && $param->{attr} eq "overflow";
                # The following should be removed and files fixed instead
                return 1 if $param->{tag} =~ /div|tr/ && $param->{attr} =~ /height|width|name|cols/;
                return 0;
            },
            'elem-img-sizes-missing' => sub {
                my $param = shift;
                if ($param->{src} eq "images/ledgersmb.png"
                 || $param->{src} =~ /payments\/img\/(up|down)\.gif/ )  {
                    return 1;
                }
                else {
                    return 0;
                }
            },
        },
    });
=cut

    #Fix source text.
    $tt_text = '<!DOCTYPE html>' . $tt_text
        if $is_snippet;

    my $v = WebService::Validator::HTML::W3C->new(
                validator_uri => 'http://fileserver:45000/w3c-validator/check',
                detailed    =>  1
            );

    my @reportable_errors;
    my @reportable_warnings;
    push @reportable_errors,
           "Line(s) with tabs: " . (join ', ', @tab_lines)
        if @tab_lines;
    push @reportable_errors,
           "Line with trailing space(s): " . (join ', ', @trailing_space_lines)
        if @trailing_space_lines;

    if ( $v->validate_markup( $tt_text )) {
        my @lines = split '\n', $tt_text;
        unshift @lines, '';
        foreach my $error ( sort {
                                    $a->line <=> $b->line or
                                    $a->msg  cmp $b->msg
                                 } @{$v->errors} ) {
            #TODO: Fix undefined detection in TT
            next if $error->msg =~ /Bad value (\w|\-|\.)* for attribute (\w|\-|\.)+ on element (\w|\-|\.)+/;
            next if $error->msg =~ /Element option without attribute label must not be empty/;
            next if $error->msg =~ /Argument \W+ isn't numeric/;
            #TODO: Should be a warning
            next if $error->msg =~ /Use CSS instead/;

            #We chose to bypass those
            next if $error->msg =~ /Element title must not be empty/;
            next if $error->msg =~ /Element head is missing a required instance of child element title/;

            #W3C isn't Dojo aware
            next if $error->msg =~ 'there is no attribute "DATA-DOJO-(CONFIG|PROPS|TYPE)"';
#            next if $error->msg =~ 'no document type declaration; will parse without validation'
#                 && !$is_snippet;
#            next if $error->msg =~ 'no document type declaration; implying "<!DOCTYPE HTML SYSTEM>"'
#                 && !$is_snippet;
            my $line = $error->line // 0;
            push @reportable_errors, reportable_line('Error',$error,$line,\@lines);
        }
        foreach my $warning ( sort {
                                    ($a->line//0) <=> ($b->line//0) or
                                    $a->msg  cmp $b->msg
                                 } @{$v->warnings} ) {
            my $line = $warning->line // 0;
            push @reportable_warnings, reportable_line('Warning',$warning,$line,\@lines);
        }
        ok(scalar @reportable_errors == 0, "Source critique for '$filename'")
            or diag(join("\n", @reportable_errors));
        TODO: {
            local $TODO = "Warnings";
            diag(join("\n", @reportable_warnings));
        }
    } else {
        fail ('Failed to validate: ' . $v->validator_error);
    }
}

content_test($_) for @on_disk;
done_testing;
