use inc::Module::Install;
name 'MojaMoja';
all_from 'lib/MojaMoja.pm';

requires 'Text::MicroTemplate';
requires 'Plack';
requires 'Router::Simple';
requires 'Data::Section::Simple';


readme_markdown_from 'lib/MojaMoja.pm';
tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests('xt');
# use_test_base;
auto_include;
WriteAll;
