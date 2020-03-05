%{
#include<stdio.h>
#include "y.tab.h"

%}

%option noyywrap

%%
[ \n\t\r]+ ;
\-?[1-9][0-9]*|0|\-?0\.[0-9]+|\-?[1-9][0-9]*\.[0-9]+ {printf("%f ", atof(yytext)); yylval.val=atof(yytext); return NUM;}
' {printf("SQ "); return SQ;}
[\,\[\]{};():=] {printf("%s ", yytext); return yytext[0];}
\"Point\" {printf("POINT "); return POINT;}
\"MultiPoint\" {printf("MULTIPOINT "); return MULTIPOINT;}
\"LineString\" {printf("LINESTRING "); return LINESTRING;}
\"MultiLineString\" {printf("MULTILINESTRING "); return MULTILINESTRING;}
\"Polygon\" {printf("POLYGON "); return POLYGON;}
\"MultiPolygon\" {printf("MULTIPOLYGON "); return MULTIPOLYGON;}
\"GeometryCollection\" {printf("GEOMETRYCOLLECTION "); return GEOMETRYCOLLECTION;}

\"Feature\" {printf("FEATURE "); return FEATURE;}
\"FeatureCollection\" {printf("FEATURECOLLECTION "); return FEATURECOLLECTION;}

\"features\" {printf("FEATURES "); return FEATURES;}
\"geometry\" {printf("GEOMETRY "); return GEOMETRY;}
\"geometries\" {printf("GEOMETRIES "); return GEOMETRIES;}
\"properties\" {printf("PROPERTIES "); return PROPERTIES;}

\"type\" {printf("TYPE "); return TYPE;}
\"coordinates\" {printf("COORDINATES "); return COORDINATES;}

\"[a-zA-Z]([0-9a-zA-Z\-]+)\" {printf("NAME "); return NAME;}

\"#[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]\" {printf("COLOR "); return COLOR;}
\" {printf("\" "); return yytext[0];}
%%

