use v6;

use CSS::Module::CSS3::Fonts::Variants;
use CSS::Module::CSS3::_Base;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Grammar;

grammar CSS::Module::CSS3::Fonts::AtFontFace
    is CSS::Module::CSS3::Fonts::Variants
    is CSS::Module::CSS3::Fonts::AtFontFace::Spec::Grammar
    is CSS::Module::CSS3::_Base
    does CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface {

    # @font-face declarations

    # ---- Functions ----
    rule format {:i('format')'(' [ <string> | <keyw> || <any-args> ] ')'}
    rule local  {:i('local')'(' [ <font-face-name> || <any-args> ] ')'}
    rule font-face-name { <font-face-name=.identifiers> | <font-face-name=.string> }
}
