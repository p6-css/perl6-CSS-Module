use v6;

class CSS::Module::CSS21::Actions { ... }

use CSS::Module::_Base::Actions;
use CSS::Module::CSS21::Spec::Interface;
use CSS::Module::CSS21::Spec::Actions;

class CSS::ModuleX::CSS21::Actions
    is CSS::Module::CSS21::Spec::Actions {

    method color:sym<system>($/) { make $.node($/) }

    # --- Functions --- #

    #| usage: attr( attribute-name <type-or-unit>? )
    method attr($/)             {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'attr', $.list($/) );
    }

    #| usage: counter(ident [, ident [,...] ])
    method counter($/) {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'counter', $.list($/) );
    }

    #| usage: counters(ident [, "string"])
    method counters($/) {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'counters', $.list($/) );
    }

    #| usage: rect(<top>, <right>, <botom>, <left>)
    method shape($/)     {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'rect', $.list($/) );
    }
    method shape-arg($/) { make $.node($/) }

   # --- Expressions --- #

    method border-style($/) { make $.list($/) }
    method border-width($/) { make $.list($/) }
    method family-name($/) { make $<family-name>.ast }
    method generic-family($/) { make $<generic-family>.ast }
    method absolute-size($/) { make $.token($<keyw>.ast) }
    method relative-size($/) { make $.token($<keyw>.ast) }
    method margin-width($/) { make $.list($/) }
    method padding-width($/) { make $.list($/) }
    method generic-voice($/) { make $.list($/) }
    method specific-voice($/) { make $.list($/) }
}

class CSS::Module::CSS21::Actions
    is CSS::ModuleX::CSS21::Actions
    is CSS::Module::_Base::Actions 
    does CSS::Module::CSS21::Spec::Interface {

    has @._proforma = 'inherit';

}
