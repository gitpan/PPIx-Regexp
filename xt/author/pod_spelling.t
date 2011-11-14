package main;

use strict;
use warnings;

BEGIN {
    eval {
	require Test::Spelling;
	Test::Spelling->import();
	1;
    } or do {
	print "1..0 # skip Test::Spelling not available.\n";
	exit;
    };
}

add_stopwords (<DATA>);

all_pod_files_spelling_ok ();

1;
__DATA__
charnames
errstr
indices
instantiation
lexed
lexes
merchantability
nav
navigational
perluniprops
POSIX
PPI
ppi
PPI's
reblesses
repl
schild
schildren
subclasses
TODO
tokenization
tokenize
tokenized
tokenizer's
tokenizers
tokenizes
tokenizing
trigraphs
unicode
unterminated
UTF
version's
wyant
XS
