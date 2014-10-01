use v6;

use CSS::Specification::_Base;

grammar CSS::Module::_Base 
    is CSS::Specification::_Base {
    # definitions common to CSS1, CSS21 and CSS3 Languages
    rule module-declaration:sym<validated> { <.ws>? <decl> <prio>? <any-arg>* <end-decl> }
    proto rule decl {*}

    # For handling undimensioned numbers and angles
    token length:sym<num> {<number>}
    token angle:sym<num>  {<number>}

    token integer     {< + - >?<uint>}
    token uint        {\d+}
    token number      {<num> <!before ['%'|\w]>}
    token uri         {<url>}
    token keyw        {<ident>}             # keyword (case insensitive)
    token identifier  {<name>}              # identifier (case sensitive)
    rule identifiers  {[ <identifier> ]+}   # E.g. font name: Times New Roman

}
