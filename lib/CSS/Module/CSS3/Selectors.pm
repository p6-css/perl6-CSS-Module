use v6;

# CSS3 Selectors Module
# specification: http://www.w3.org/TR/2011/REC-css3-selectors-20110929/
# Notes:
# -- have relaxed negation rule to take a list of arguments - in common use
#    and supported  by major browsers.

class CSS::Module::CSS3::Selectors::Actions {...}

use CSS::Module::CSS3::_Base;

grammar CSS::Module::CSS3::Selectors:ver<20110929.000>
    is CSS::Module::CSS3::_Base {

    # extensions:
    # ----------
    # inherited combinators: '+' (adjacent), '>' (child)
    rule combinator:sym<sibling> { '~' }

    rule no-namespace {<?>}
    rule wildcard {'*'}
    rule namespace-prefix {[<prefix=.Ident>|<prefix=.wildcard>|<prefix=.no-namespace>]'|'}

    # use <qname> in preference to <type_selector>
    # - see http://www.w3.org/TR/2008/CR-css3-namespace-20080523/#css-qnames
    rule qname      {<namespace-prefix>? <element-name>}
    rule universal  {<namespace-prefix>? <element-name=.wildcard>}
    rule simple-selector { [<qname><!before '|'>|<universal>][<id>|<class>|<attrib>|<pseudo>]*
                               | [<id>|<class>|<attrib>|<pseudo>]+ }

    rule type-selector {<namespace-prefix>? <element-name>}
    
    rule attrib        {'[' <Ident> [ <attribute-selector> [<Ident>|<string>] ]? ']'}

    rule term:sym<unicode-range> {:i'U+'<unicode-range>}

    # inherited from base: = ~= |=
    rule attribute-selector:sym<prefix>    {'^='}
    rule attribute-selector:sym<suffix>    {'$='}
    rule attribute-selector:sym<substring> {'*='}

    # to compute a.n + b
    proto rule structural-expr {*}
    rule structural-expr:sym<keyw> {:i [ odd | even ] & <keyw> }
    token sign { <[ \+ \- ]> }
    rule structural-expr:sym<expr> {
        [:i <op=.sign>?$<int:a>=<.uint>?<op(rx:i/n/)> [<op=.sign> $<int:b>=<.uint>]?
        ||  <op=.sign>?$<int:b>=<.uint>
        ]
    }

    rule structural-selector {:i $<Ident>=[[nth|first|last|nth\-last]\-[child|of\-type]]'(' [ <expr=.structural-expr> || <any-args> ] ')'}
    rule pseudo-function:sym<structural-selector> {<structural-selector>}
    rule negation-expr {[<type-selector> | <universal> | <id> | <class> | <attrib> | [$<nested>=<?before [:i':not(']> || <?>] <pseudo> | <any-arg> ]+}
    rule pseudo-function:sym<negation>  {:i'not(' [ <negation-expr> || <any-args> ] ')'}

}

class CSS::Module::CSS3::Selectors::Actions
    is CSS::Module::CSS3::_Base::Actions {

    use CSS::AST :CSSValue;

    method combinator:sym<sibling>($/)  { make $.token('~') }

    method no-namespace($/)     { make $.token('', :type(CSSValue::ElementNameComponent)) }
    method namespace-prefix($/) { make $.token( $<prefix>.ast, :type(CSSValue::NamespacePrefixComponent)) }
    method wildcard($/)         { make ~$/ }
    method type-selector($/)    { make $.node($/) }
    method qname($/)            { make $.token( $.node($/), :type(CSSValue::QnameComponent)) }
    method universal($/)        { make $.token( $.node($/), :type(CSSValue::QnameComponent)) }

    method attribute-selector:sym<prefix>($/)    { make ~$/ }
    method attribute-selector:sym<suffix>($/)    { make ~$/ }
    method attribute-selector:sym<substring>($/) { make ~$/ }

    method term:sym<unicode-range>($/) { make $.node($/) }
    method structural-selector($/)  {
        my $ident = $<Ident>.lc;
        return $.warning('usage '~$ident~'(an[+/-b]|odd|even) e.g. "4" "3n+1"')
            if $<any-args>;

        my %node = %( $.node($/) );
        %node<ident> = $ident;

        make $.token( %node, :type(CSS::AST::CSSSelector::PseudoFunction));
    }
    method pseudo-function:sym<structural-selector>($/)  { make $<structural-selector>.ast }

    method sign($/) {make ~$/ }
    method structural-expr:sym<keyw>($/) { make $.list($/) }
    method structural-expr:sym<expr>($/) { make $.list($/) }
    method nth-functor($/)               { make $/.lc  }

    method negation-expr($/) {
        return $.warning('bad :not() argument', ~$<any-arg>)
            if $<any-arg>;
        return $.warning('illegal nested negation', ~$<pseudo>)
            if $<nested>;
        make $.list($/);
    }

    method pseudo-function:sym<negation>($/) {
        return $.warning('missing/incorrect arguments to :not()', ~$<any-args>)
            if $<any-args>;
        return unless $<negation-expr>.ast;
        make $.pseudo-func('not', $<negation-expr>.ast);
    }
}

