#!perl

use strict;
use warnings;

use File::Find;
use Test::More;

use LedgerSMB::Sysconfig;

use Hash::Merge qw( merge );
use Scalar::Util;

use Template;
use Template::Config;
use Template::Stash;
use Template::VMethods;

use SGML::Parser::OpenSP;
my $parser = SGML::Parser::OpenSP->new();
$parser->handler(bless({}, 'main'));

use WebService::Validator::HTML::W3C;

use Data::Printer;

$Template::Stash::PRIVATE = undef;  # Make sure we can access variables with a leading underscore

my $validator_uri = $ENV{'VALIDATOR_URI'} // 'http://localhost:45000/w3c-validator/check';

my @on_disk = ();

sub collect {
    my $module = $File::Find::name;
    return if $module !~ m/\.html$/
           || $module =~ m/\/pod\//
           || $module =~ m(/js/)
           || $module =~ m(/js-src/(dijit|dojo|util)/);

#    return if $module ne 'UI/welcome.html';
    push @on_disk, $module
}
find(\&collect, $ARGV[0] // 'UI/');

plan tests => scalar(@on_disk);

sub _strip_pattern {
    my ($text,$pattern,$keep_newlines) = @_;
    while ( $text =~ /$pattern/ ) {
        my ($v1,$v2,$v3) = ($1,$2,$3);
        $v2 =~ s~[^\n]+~~gs;
        $text = ($v1 // '') . ($v2 // '') . ($v3 // '');
    }
    return $text;
}

sub max ($$) { $_[$_[0] < $_[1]] }
sub min ($$) { $_[$_[0] > $_[1]] }

sub _reportable_line {
    my ($prefix,$p,$msg,$line,$lines) = @_;
    $line //= 0;
    my @context = $prefix . ':' . $p . ' at ' . $line . ' - ' .$msg;
    if ( $line ) {
        push @context, '# in {{ ';
        for (my $i = max(1,$line-2); $i <= min($line+2,scalar(@$lines)); $i++) {
            push @context, '# ' . $i . ': ' . $lines->[$i-1];
        }
        push @context,  '# }}';
    }
    push @context, '';
    return [@context];
}

sub _get_vmethod {
    my ($value) = @_;
    return $Template::VMethods::TEXT_VMETHODS->{$value}
        // $Template::VMethods::HASH_VMETHODS->{$value}
        // $Template::VMethods::LIST_VMETHODS->{$value};
}

sub _def {
    my (@w) = @_;
    my $w0 = shift @w;
    my $hash = { $w0 => "LSMB_$w0" };
    if ( 1 == @w ) {
        my $fn = _get_vmethod($w[0]);
        if ($fn) {
#            $hash->{$w0} = $fn;
            return $hash;
        }
    }
    $hash->{$w0} = _def(@w) if 0 < @w;
    return $hash;
}

sub _hash_included {
    my ($hash,$sub,$level) = @_;

    return 0 if ref $hash ne ref $sub;
    return $hash eq $sub if 'HASH' ne ref $hash && 'HASH' ne ref $sub;

    for (keys %$sub) {
        if ( defined $hash->{$_} ) {
            return 0 if !_hash_included($hash->{$_},$sub->{$_},$level+1);
        }
        else {
            return _get_vmethod $sub->{$_};
        }
    }
    return 1;
}

my @reportable_errors;
my @reportable_warnings;
my @lines;

sub content_test {
    my ($filename) = @_;
    my $has_body = 0;
    my $has_doctype = 0;
    my $ui_header_used = $filename =~ m/UI\/lib\//;
    my $is_snippet = $filename !~ m#(log(in|out))|main|setup/#
                  || $filename =~ m#setup/ui-db-credentials|'lib/ui-header#;

    my (@tab_lines, @trailing_space_lines);
    my $text = '';

    @reportable_errors = ();
    @reportable_warnings = ();
    @lines = ();

    open my $fh, "<$filename";
    while (<$fh>) {
        push @tab_lines, ($.) if /\t/;
        push @trailing_space_lines, ($.) if / $/;
        $has_body = 1 if /<body\b/;
        $has_doctype = 1 if /<!DOCTYPE\b/i;
        $ui_header_used = 1 if /ui-header\.html/;
        $is_snippet = 1
            if /HTML Snippet, for import only/;
        $text .= $_;
    }
    close $fh;
    $parser->{ui_header_used} = $ui_header_used;
    $parser->{is_snippet} = $is_snippet;
    $parser->{has_doctype} = $has_doctype;
    $parser->{has_body} = $has_body;

    #Strip comments, keep lines for error reporting
    $text = _strip_pattern($text,qr/(.*)(\<!--.+-->)(.*)/s);
    $text = ("<?lsmb PROCESS 'elements.html'; PROCESS 'dynatable.html' ?>"
          . $text)
          if $is_snippet;

    push @reportable_errors,
           "Line(s) with tabs: " . (join ', ', @tab_lines)
        if @tab_lines;
    push @reportable_errors,
           "Line with trailing space(s): " . (join ', ', @trailing_space_lines)
        if @trailing_space_lines;

    my $tt_config = {
        START_TAG => quotemeta('<?lsmb'),
        END_TAG => quotemeta('?>'),
        INCLUDE_PATH => ['templates/demo','UI/Contact','UI','UI/lib'],
        ENCODING => 'utf8',
        DELIMITER => ';',
        PRE_CHOMP => 1,
        POST_CHOMP => 1,
        TRIM => 1,
        INTERPOLATE => 1,
        STRICT => 1
    };
    # Define the strict minimum and let the others be set at runtime
    my $vars = {
        dojo_theme => $LedgerSMB::Sysconfig::dojo_theme,
        dojo_built => $LedgerSMB::Sysconfig::dojo_built,
        dojo_location => $LedgerSMB::Sysconfig::dojo_location,
        USER => {
            id => 1,
            dateformat => 'yyyy-mm-dd',
            language => 'en_CA'
        },
        SETTINGS => {
            default_currency => 'USD',
            decimal_places => 2
        },
        refresh => {
            delay => int(1 + rand 100),
            url => 'url=http://www.ledgersmb.org'
        },
        report => {
            sorted_row_ids => 'rid1',
            rheads => {
                ids => {
                    1 => {
                        path => 'rpath1',
                        props => {
                            account_type => 'A',
                            section_for => 'Test',
                            account_number => '1234',
                            account_description => 'Description 1234'
                        }
                    }
                }
            },
#            cheads.ids.keys,
            sorted_col_ids => 'cid1',
            cheads => {
                ids => {
                    1 => {
                        props => {
                            description => 'col1',
                            from_date => '2004-05-06'
                        }
                    }
                }
            }
        },
        row_count => int(0.5 + rand 1),
        level => int( 1 + rand 5 ),
        DIVS => 'address',
        _buttonInputDisabled => int(0.5 + rand 1) ? 'disabled' : '',
        PLUGINS => undef,
        text => sub { return $_[0] },
    };
    my $tt_text;
    my $tt = Template->new($tt_config);

    while ( !$tt->process(\$text,$vars,\$tt_text)) {

        my $error = $tt->error();

        if ( $error->[0] eq "var.undef" ) {
            if ( $error->[1] =~ /^undefined variable: ((?:\w+|\.)+)/) {
                my $v = $1;
                my @w = split /\./,($v.'.');
                my $v1 = _def(@w);
                if (_hash_included($vars,$v1,1)) {
                    local $TODO = "Variable already defined";
                    ok(0,$v);
                    last;
                } else {
                    my $tag = $w[0];    # Try to handle duplicates
                    $vars->{$tag} = merge( $v1->{$tag}, $vars->{$tag} );
                };
            } else {
                ok(0,$error->[1]);
                last;
            }
        } else {
            ok(0,$error->[1]);
            last;
        }
    }

    if ( !$tt_text ) {
        # We weren't able to get a parsed TT output, let's strip the lsmb blocks
        # and send that to W3C
        # Fix source text. Template statements have to be removed for now.
        # IF/ELSE/END branches will clash though. - YL
        # Strip <?lsmb ... ?>
        $tt_text = $text;
        $tt_text =~ s/<\?lsmb\s+text\((['"])(.+?)\1\)\s*-?\?>/$1$2$1/g;
        $tt_text =~ s/<\?lsmb\b.*?\s*\?>//gs;
    }
    if ( $tt_text ) {
        #Fix source text.
        $tt_text = '<!DOCTYPE html>' . $tt_text
            if $is_snippet && !$ui_header_used
            || $has_body && !($has_doctype || $ui_header_used);

        my $v = WebService::Validator::HTML::W3C->new(
                    validator_uri => $validator_uri,
                    detailed      => 1
                );

        if ( $v->validate_markup( $tt_text )) {
            @lines = split '\n', $tt_text;
            unshift @lines, '';

            if ( $v->errorcount ) {
                foreach my $error ( sort {
                                            $a->line <=> $b->line or
                                            $a->msg  cmp $b->msg
                                         } @{$v->errors}
                                  )
                {
                    if ( $error->msg =~ /Bad value Expires for attribute http-equiv on element meta/) {
                        TODO: {
                            local $TODO = 'Remove HTML4 Expires';
                            ok(0,$error->msg);
                        }
                        next;
                    }
                    if ( $error->msg =~ /Bad value Pragma for attribute http-equiv on element meta/) {
                        TODO: {
                            local $TODO = 'Remove HTML4 Caching';
                            ok(0,$error->msg);
                        }
                        next;
                    }
                    if ( $error->msg =~ /Use CSS instead/) {
                        TODO: {
                            local $TODO = 'Remove inline styles';
                            ok(0,$error->msg);
                        }
                        next;
                    }

    #   Failed test '" in an unquoted attribute value. Probable causes: Attributes running together or a URL query string in an unquoted attribute value.
    #   Failed test '"REQUIRED" is not a member of a group specified for any attribute
    #   Failed test '' in an unquoted attribute value. Probable causes: Attributes running together or a URL query string in an unquoted attribute value.
    #   Failed test '= in an unquoted attribute value. Probable causes: Attributes running together or a URL query string in an unquoted attribute value.
    #   Failed test 'Attribute cols not allowed on element div at this point.
    #   Failed test 'Attribute height not allowed on element tr at this point.
    #   Failed test 'Attribute name not allowed on element div at this point.
    #   Failed test 'Attribute overflow not allowed on element div at this point.
    #   Failed test 'Attribute value missing.
    #   Failed test 'Bad value _download for attribute target on element a: Reserved keyword download used.
    #   Failed test 'Bad value _new for attribute target on element a: Reserved keyword new used.
    #   Failed test 'Bad value style='white-space:nowrap' for attribute colspan on element td: Expected a digit but saw s instead.
    #   Failed test 'Duplicate ID .
    #   Failed test 'Duplicate ID buttonrow.
    #   Failed test 'Duplicate ID disclaimer.
    #   Failed test 'Element form not allowed as child of element tr in this context. (Suppressing further errors from this subtree.)
    #   Failed test 'End tag for  body seen, but there were unclosed elements.
    #   Failed test 'Start tag body seen but an element of the same type was already open.
    #   Failed test 'Start tag for table seen but the previous table is still open.
    #   Failed test 'Start tag form seen in table.
    #   Failed test 'Stray end tag form.
    #   Failed test 'Stray end tag table.
    #   Failed test 'Stray end tag td.
    #   Failed test 'Stray end tag tr.
    #   Failed test 'Stray start tag td.
    #   Failed test 'Stray start tag tr.
    #   Failed test 'The for attribute of the label element must refer to a non-hidden form control.
    #   Failed test 'Unclosed element div.
    #   Failed test 'Unclosed elements on stack.
    #   Failed test 'an attribute value specification must start with a literal or a name character
    #   Failed test 'document type does not allow element "DIV|TD|TH|TR" here
    #   Failed test 'end tag for element "SCRIPT" which is not open
    #   Failed test 'general entity "order_by" not defined and no default entity
    #   Failed test 'reference to entity "order_by" for which no system identifier could be generated
    #   Failed test 'td start tag in table body.
                    #Cope with TT process being unable to produce a parsed output
                    # - General
                    next if $error->msg =~ /Bad value\s+for attribute action on element form: Must be non-empty/;
                    next if $error->msg =~ /Bad value\s+for attribute id on element (form|div|span|th|tr|td): An ID must not be the empty string/;
                    # - Tables
                    next if $error->msg =~ /Table column [0-9]+ established by element (col|th|td) has no cells beginning in it/;
                    next if $error->msg =~ /A table row was [0-9]+ columns wide, which is less than the column count established using column markup/;
                    next if $error->msg =~ /Row [0-9]+ of a row group established by a tbody element has no cells beginning on it/;
                    next if $error->msg =~ /Table columns in range [0-9]+.[0-9]+ established by element (td|th) have no cells beginning in them/;
                    next if $error->msg =~ /Bad value\s+for attribute colspan on element (th|td): (Must be non-empty|The empty string is not a valid positive integer)/;
                    # - Entities
                    next if $error->msg =~ /general entity "(quot|nbsp)" not defined and no default entity/;
                    next if $error->msg =~ /reference to entity "(quot|nbsp)" for which no system identifier could be generated/;
                    # - Prologue is set in ui-header, so spurious epilogue is ok
                    next if $error->msg =~ /no document type declaration; will parse without validation/
                         && $ui_header_used;
                    next if $error->msg =~ /end tag for element "HTML" which is not open/
                         && $ui_header_used;

                    #We chose to bypass those
                    next if $error->msg =~ /Element head is missing a required instance of child element title/;

                    #W3C isn't Dojo aware
                    next if $error->msg =~ /there is no attribute "DATA-[A-Z\-]+"/;
                    next if $error->msg =~ /Bad value (button|combobox|listbox|option|presentation|slider|spinbutton) for attribute role on element (div|input|table|tbody|td|tr)/;

                    push @reportable_errors, _reportable_line('W3C','Error',$error->msg,$error->line,\@lines);
                }
            }
            if ( $v->warningcount ) {
                foreach my $warning ( sort {
                                            ($a->line//0) <=> ($b->line//0) or
                                            $a->msg  cmp $b->msg
                                         } @{$v->warnings}
                                    )
                {
                    push @reportable_warnings, _reportable_line('W3C','Warning',$warning->msg,$warning->line,\@lines);
                }
            }
        } else {
            fail ('Failed to validate: ' . $v->validator_error);
        }
    }
    $parser->parse_string($tt_text);
    if ( scalar @reportable_warnings ) {
        TODO: {
            local $TODO = "Warnings";
            local $\ = "\n";
            for my $warning (@reportable_warnings) {
                ok(0,join "\n",@$warning);
            }
        }
    }
    if ( scalar @reportable_errors ) {
        local $\ = "\n";
        ok(0, "Source critique for '$filename'");
        for my $error (@reportable_errors) {
            ok(0,join "\n",@$error);
        }
    } else {
        ok(1, "Source critique for '$filename'")
    }
}

subtest $_ => \&content_test, $_ for sort @on_disk;

sub error
{
    my $self = shift;
    my $erro = shift;
    my $mess = $parser->split_message($erro);
    my $Text = $mess->{primary_message}->{Text};
    my $LineNumber = $mess->{primary_message}->{LineNumber};

    return if ($Text =~ /no internal or external document type declaration subset/
             ||$Text =~ /element "HTML" undefined/)
         && ( $parser->{is_snippet} && !$parser->{ui_header_used}
            || $parser->{has_body} && !($parser->{has_doctype} || $parser->{ui_header_used}));

    push @reportable_errors, _reportable_line('OpenSC','Error',$Text,$LineNumber,\@lines)
        if ( $mess->{primary_message}->{Severity} eq 'E' );

    push @reportable_warnings, _reportable_line('OpenSC','Warning',$Text,$LineNumber,\@lines)
        if ( $mess->{primary_message}->{Severity} eq 'W' );
}

done_testing;

# The 2 method generate different sets of errors.
#   OpenSC:"ALIGN" is not a member of a group specified for any attribute
#   OpenSC:"NOSHADE" is not a member of a group specified for any attribute
#   OpenSC:"NOWRAP" is not a member of a group specified for any attribute
#   OpenSC:"REQUIRED" is not a member of a group specified for any attribute
#   OpenSC:"XA0" is not a function name
#   OpenSC:an attribute specification must start with a name or name token
#   OpenSC:an attribute value must be a literal unless it contains only name characters
#   OpenSC:an attribute value specification must start with a literal or a name character
#   OpenSC:end tag for element "HTML" which is not open
#   OpenSC:end tag for element "SCRIPT" which is not open
#   OpenSC:end tag for element "TABLE" which is not open
#   OpenSC:end tag for element "TH" which is not open
#   OpenSC:end tag for element "TR" which is not open
#   OpenSC:general entity "amp" not defined and no default entity
#   OpenSC:general entity "callback" not defined and no default entity
#   OpenSC:general entity "country" not defined and no default entity
#   OpenSC:general entity "credit" not defined and no default entity
#   OpenSC:general entity "employeenumber" not defined and no default entity
#   OpenSC:general entity "entity" not defined and no default entity
#   OpenSC:general entity "file" not defined and no default entity
#   OpenSC:general entity "first" not defined and no default entity
#   OpenSC:general entity "format" not defined and no default entity
#   OpenSC:general entity "gt" not defined and no default entity
#   OpenSC:general entity "id" not defined and no default entity
#   OpenSC:general entity "last" not defined and no default entity
#   OpenSC:general entity "lt" not defined and no default entity
#   OpenSC:general entity "nbsp" not defined and no default entity
#   OpenSC:general entity "order" not defined and no default entity
#   OpenSC:general entity "quot" not defined and no default entity
#   OpenSC:general entity "ref" not defined and no default entity
#   OpenSC:general entity "user" not defined and no default entity
#   OpenSC:no document element
#   OpenSC:no document type declaration; will parse without validation
#   OpenSC:no internal or external document type declaration subset; will parse without validation
#   OpenSC:prolog can't be omitted unless CONCUR NO and LINK EXPLICIT NO and either IMPLYDEF ELEMENT YES or IMPLYDEF DOCTYPE YES

#   W3C:"REQUIRED" is not a member of a group specified for any attribute
#   W3C:= in an unquoted attribute value. Probable causes: Attributes running together or a URL query string in an unquoted attribute value.
#   W3C:Attribute cols not allowed on element div at this point.
#   W3C:Attribute height not allowed on element tr at this point.
#   W3C:Attribute name not allowed on element div at this point.
#   W3C:Attribute overflow not allowed on element div at this point.
#   W3C:Attribute value missing.
#   W3C:Bad value _download for attribute target on element a: Reserved keyword download used.
#   W3C:Bad value _new for attribute target on element a: Reserved keyword new used.
#   W3C:Duplicate ID .
#   W3C:Duplicate ID buttonrow.
#   W3C:Duplicate ID disclaimer.
#   W3C:Element form not allowed as child of element tr in this context. (Suppressing further errors from this subtree.)
#   W3C:End tag for  body seen, but there were unclosed elements.
#   W3C:Start tag body seen but an element of the same type was already open.
#   W3C:Start tag for table seen but the previous table is still open.
#   W3C:Start tag form seen in table.
#   W3C:Stray end tag form.
#   W3C:Stray end tag table.
#   W3C:Stray end tag td.
#   W3C:Stray end tag tr.
#   W3C:Stray start tag td.
#   W3C:Stray start tag tr.
#   W3C:The for attribute of the label element must refer to a non-hidden form control.
#   W3C:Unclosed element div.
#   W3C:Unclosed elements on stack.
#   W3C:an attribute value specification must start with a literal or a name character
#   W3C:end tag for element "SCRIPT" which is not open
#   W3C:general entity "order_by" not defined and no default entity
#   W3C:reference to entity "order_by" for which no system identifier could be generated
#   W3C:td start tag in table body.
