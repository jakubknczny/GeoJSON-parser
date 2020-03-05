## GeoJSON Parser

A simple YACC & Lex GeoJSON parser to create an .hmtl file to draw shapes from the GeoJSON. 
You need to add your own Google Maps API key to the template.y file.

'''
yacc -d template.y 
'''
should produce files y.tab.c and y.tab.h, then it is possible to:
'''
#include "y.tab.h"
'''
and 
'''
lex template.l
gcc lex.yy.c y.tab.c 
./a.out < fcall.txt
'''

The .html works as intended, however there are some problems with the parser: 2 shift/reduce conflicts and 13 reduce/reduce conflicts.
Since they do not spoil the usability, I do not care much, though.