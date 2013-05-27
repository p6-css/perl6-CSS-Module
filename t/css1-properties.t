#!/usr/bin/env perl6

use Test;

use CSS::Language::CSS1::Actions;
use CSS::Language::CSS1;

use CSS::Language::CSS21::Actions;
use CSS::Language::CSS21;

use CSS::Language::CSS3;

use lib '.';
use t::AST;

my $css1_actions = CSS::Language::CSS1::Actions.new;
my $css21_actions = CSS::Language::CSS21::Actions.new;
my $css3_actions = CSS::Language::CSS3::Actions.new;

my %seen;

for (
    {prop => 'background-color', decl => '#37a', expr => [color => {r => 0x33, g => 0x77, b => 0xAA}],
    },
    {prop => 'background-image', decl => 'url(images/ok.png)', expr => [url => 'images/ok.png'],
    },
    {prop => 'background-repeat', decl => 'Repeat-x', expr => [keyw => 'repeat-x'],
    },
    {prop => 'background-attachment', decl => 'FiXed', expr => [keyw => 'fixed'],
    },
    {prop => 'background-position', decl => '100% 90%', expr => ["percentage" => 100, "percentage" => 90],
    },
    {prop => 'background', decl => 'url(chess.png) gray 50% repeat scroll', 
     expr => ["background-image" => ["url" => "chess.png"],
              "background-color" => ["color" => {"r" => 128, "g" => 128, "b" => 128}],
              "background-position" => ["percentage" => 50],
              "background-repeat" => ["keyw" => "repeat"],
              "background-attachment" => ["keyw" => "scroll"]],
    },
    {prop => 'border-top-width', decl => 'thick', expr => ["keyw" => "thick"]
    },
    {prop => 'border-width', decl => '2ex 1.5em 3ex 2em',
     box => ["top" => ["length" => 2],
             "right" => ["length" => 1.5],
             "bottom" => ["length" => 3],
             "left" => ["length" => 2]],
    },
    {prop => 'border-color', decl => '#a7f #aa77ff rgb(100,150,20) aqua',
     box => ["top" => ["color" => {"r" => 170, "g" => 119, "b" => 255}],
             "right" => ["color" => {"r" => 170, "g" => 119, "b" => 255}],
             "bottom" => ["color" => {"r" => 100, "g" => 150, "b" => 20}],
             "left" => ["color" => {"r" => 0, "g" => 255, "b" => 255}]],
    },
    {prop => 'border-style', decl => 'groove', expr => ["keyw" => "groove"],
    },
    {prop => 'clear', decl => 'both', expr => ["keyw" => "both"],
    },
    {prop => 'color', decl => '#3377aa', expr => [color => {r => 0x33, g => 0x77, b => 0xAA}],
    },
    {prop => 'display', decl => 'list-item', expr => ["keyw" => "list-item"],
    },
    {prop => 'float', decl => 'left', expr => ["keyw" => "left"],
    },
    {prop => 'font-family', decl => 'Gill, "Helvetica", sans-serif',
     expr => ["family-name" => "Gill",
              "family-name" => "Helvetica",
              "generic-family" => "sans-serif"],
    },
    {prop => 'font-family', decl => 'New Century Schoolbook',  
     expr => ["family-name" => "New Century Schoolbook",],
    },
    {prop => 'font-style', decl => 'italic', expr => ["keyw" => 'italic'],
    },
    {prop => 'font-variant', decl => 'small-caps', expr => ["keyw" => 'small-caps'],
    },
    {prop => 'font-weight', decl => 'bolder', expr => ["keyw" => 'bolder'],
    },
    {prop => 'font-weight', decl => '800', expr => ["number" => '800'],
    },
    {prop => 'font-size', decl => '12pt', expr => [length => '12'],
    },
    {prop => 'font-size', decl => '150%', expr => [percentage => '150'],
    },
    {prop => 'font-size', decl => 'Larger', expr => [relative-size => 'larger'],
    },
    {prop => 'font', decl => '12pt/14pt sans-serif',
     expr => ["font-size" => ["length" => 12],
              "line-height" => ["length" => 14],
              "font-family" => ["generic-family" => "sans-serif"]],
    },
    {prop => 'font', decl => 'normal small-caps 120%/120% fantasy',
     expr => ["font-style" => "normal",
              "font-variant" => "small-caps",
              "font-size" => ["percentage" => 120],
              "line-height" => ["percentage" => 120],
              "font-family" => ["generic-family" => "fantasy"]],
    },
    {prop => 'letter-spacing', decl => 'normal', expr => ["keyw" => "normal"]
    },
    {prop => 'line-height', decl => '120%', expr => ["percentage" => 120]
    },
    {prop => 'list-style-type', decl => 'square', expr => ["keyw" => "square"],
    },
    {prop => 'list-style-image', decl => 'url(snoopy.png)', expr => ["uri" => "snoopy.png"],
    },
    {prop => 'list-style-position', decl => 'outside', expr => [keyw => 'outside'],
    },
    {prop => 'list-style', decl => 'url(http://png.com/ellipse.png) disc outside',
     expr => ["list-style-image" => ["uri" => "http://png.com/ellipse.png"],
              "list-style-type" => ["keyw" => "disc"],
              "list-style-position" => ["keyw" => "outside"]],
    },
    {prop => 'overflow', decl => 'scroll', expr => ["keyw" => "scroll"],
    },
    {prop => 'padding-bottom', decl => '2em', expr => ["length" => 2]
    },
    {prop => 'position', decl => 'absolute', expr => ["keyw" => "absolute"],
    },
    {prop => 'margin-top', decl => '1.25ex', expr => ["length" => 1.25]
    },
    {prop => 'margin', decl => '1.2ex 1.5em 125% 0',
     box => ["top" => ["length" => 1.2],
             "right" => ["length" => 1.5],
             "bottom" => ["percentage" => 125],
             "left" => ["length" => 0]],
    },
    {prop => 'margin', decl => '1.2ex 1.5em',
     box => ["top" => ["length" => 1.2],
             "right" => ["length" => 1.5],
             "bottom" => ["length" => 1.2],
             "left" => ["length" => 1.5]]
    },
    {prop => 'text-decoration', decl => 'Underline', expr => ["keyw" => "underline"]
    },
    {prop => 'text-transform', decl => 'uppercase', expr => ["keyw" => "uppercase"]
    },
    {prop => 'text-align', decl => 'justify', expr => ["keyw" => "justify"]
    },
    {prop => 'text-decoration', decl => 'underline', expr => ["keyw" => "underline"]
    },
    {prop => 'vertical-align', decl => 'text-top', expr => ["keyw" => "text-top"]
    },
    {prop => 'width', decl => '55mm', expr => ["length" => 55],
    },
    {prop => 'word-spacing', decl => '1.5em', expr => ["length" => 1.5]
    },
    {prop => 'white-space', decl => 'nowrap', expr => ["keyw" => "nowrap"],
    },
    {prop => 'z-index', decl => '3', expr => ["integer" => 3],
    },

    ) {

    my %test = %$_;
    my $prop = %test<prop>;

    my %declarations;

    if %test<box> {
        for @(%test<box>) {
            my ($edge, $val) = $_.kv;
            %declarations{$prop.lc ~ '-' ~ $edge} = {expr => $val}
        }
    }
    else {
        %declarations{ $prop.lc } = {expr => %test<expr>};
    }

    %test<ast> = %declarations;

    my $input = $prop ~ ':' ~ %test<decl>;

    $css1_actions.reset;
    my $p1 = CSS::Language::CSS1.parse( $input, :rule('declaration-list'), :actions($css1_actions));
    t::AST::parse_tests($input, $p1, :rule('decl'), :suite('css1'),
                         :warnings($css1_actions.warnings),
                         :expected(%test) );

    $css21_actions.reset;
    my $p21 = CSS::Language::CSS21.parse( $input, :rule('declaration-list'), :actions($css21_actions));
    t::AST::parse_tests($input, $p21, :rule('decl'), :suite('css21'),
                         :warnings($css21_actions.warnings),
                         :expected(%test) );

    $css3_actions.reset;
    my $p3 = CSS::Language::CSS3.parse( $input, :rule('declaration-list'), :actions($css3_actions));
    t::AST::parse_tests($input, $p3, :rule('decl'), :suite('css3'),
                         :warnings($css3_actions.warnings),
                         :expected(%test) );

    unless %seen{$prop.lc}++ {
        # usage and inheritence  tests
        my $junk = $prop ~ ': junk +-42';

        $css1_actions.reset;
        $p1 = CSS::Language::CSS1.parse( $junk, :rule('declaration-list'), :actions($css1_actions));
        is($p1.Str, $junk, "$prop: able to parse unexpected input");

        ok($css1_actions.warnings.grep({/^usage:/}), "css1 $prop : unexpected input produces warning")
            or diag $css1_actions.warnings;

        $css21_actions.reset;
        $p21 = CSS::Language::CSS21.parse( $junk, :rule('declaration-list'), :actions($css21_actions));
        is($p21.Str, $junk, "css21 $prop: able to parse unexpected input");

        $css3_actions.reset;
        $p3 = CSS::Language::CSS3.parse( $junk, :rule('declaration-list'), :actions($css3_actions));
        is($p3.Str, $junk, "css3 $prop: able to parse unexpected input");

       ok($css3_actions.warnings, "$prop : unexpected input produces warning")
            or diag $css3_actions.warnings;

        for <inherit initial> -> $misc {
            my $decl = $prop ~ ': ' ~ $misc;

            my @_expr = ($misc => True);
            my %ast = %test<box>
                ?? <top right bottom left>.map({($prop.lc ~ '-' ~ $_) => [expr => @_expr]})
                !! ($prop.lc => [expr => @_expr]);

            unless $misc eq 'initial' { # applicable to css3 only
                $css21_actions.reset;
                $p21 = CSS::Language::CSS21.parse( $decl, :rule('declaration-list'), :actions($css21_actions));

                t::AST::parse_tests($decl, $p21, :rule('declaration-list'), :suite('css21'),
                                    :warnings($css21_actions.warnings),
                                    :expected({ast => %ast}) );

            }

            $css3_actions.reset;
            $p3 = CSS::Language::CSS3.parse( $decl, :rule('declaration-list'), :actions($css3_actions));

            t::AST::parse_tests($decl, $p3, :rule('decl'), :suite('css3'),
                                :warnings($css3_actions.warnings),
                                :expected({ast => %ast}) );
        }
    }

}

done;
