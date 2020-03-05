%{
/*

	THIS PROGRAM DOES NOT DRAW MULTIPOLYGONS.
	I DID NOT WRITE C CODE TO DO THAT, BECAUSE IT WOULD BE VERY SIMILAR TO OTHER MULTI* GEOMETRIES AND WOULD REQUIRE A LOT OF REDUNDANT WORK.


*/

#include<stdio.h>
#include<stdlib.h>
int yylex();
int yyerror(char *);
extern int yylineno;

FILE *file;
int i;
int arrayOfTwoOrMorePositionsBegin = 1 ;
int arrayOfArrayOfTwoOrMorePositionsBegin = 1;
int ringBegin = 1;
int ringringBegin = 1;
int coordsCounter = 0 ;
int mainCoordsCounter = 0;

%}
%union{
	double val;
}

%type<val> NUM

%token NUM NAME
%token POINT MULTIPOINT LINESTRING MULTILINESTRING POLYGON MULTIPOLYGON GEOMETRYCOLLECTION
%token FEATURE FEATURECOLLECTION
%token FEATURES GEOMETRY GEOMETRIES PROPERTIES 
%token TYPE COORDINATES
%token COLOR SQ

%start start

%%
start:	| newObject start 
	;
newObject:
	| geometry 
	| feature
	| featureCollection 
	;
geometry: 
	  point 
	| multiPoint
	| lineString
	| multiLineString
	| polygon
	| multiPolygon
	| geometryCollection
	;
pointPosition:
	'[' NUM ',' NUM position0 ']'
	{
		fprintf(file, "        var coords%d = ", coordsCounter);
		fprintf(file, "{lat: %f, lng: %f };\n", $4, $2);
	}
	;

position0:
	| ',' NUM 
	; 
arrayOfPositions: '[' pos ']' ;
pos:	| pos1 
	;
pos1:	arrayOfPositionsPosition | arrayOfPositionsPosition ',' pos1 
	;
arrayOfPositionsPosition:
	'[' NUM ',' NUM position0 ']'
	{
		fprintf(file, "        var coords%d = {lat: %f, lng: %f };\n", coordsCounter, $4, $2);
	}
	;

arrayOfTwoOrMorePositions: '[' arrayOfTwoOrMorePositionsPosition ',' arrayOfTwoOrMorePositionsPosition pos2 ']' ;
pos2: | ',' arrayOfTwoOrMorePositionsPosition pos2 ;
arrayOfTwoOrMorePositionsPosition:
	'[' NUM ',' NUM position0 ']'
	{
		if(arrayOfTwoOrMorePositionsBegin == 1)
		{
			fprintf(file, "        var coords%d = [\n", coordsCounter);
			fprintf(file, "          {lat: %f, lng: %f }", $4, $2);
			arrayOfTwoOrMorePositionsBegin = 0;
		}
		else
		{
			fprintf(file, ",\n          {lat: %f, lng: %f }", $4, $2);
		}
	}
	;

arraYOfArraysOfTwoOrMorePositions: '[' arr0 ']' ;
arr0: | arrayOfTwoOrMorePositions2 {
		fprintf(file, "]\n");
		arrayOfTwoOrMorePositionsBegin = 1;
	} arr1;
arr1: 	| ',' arrayOfTwoOrMorePositions2
		{
			fprintf(file, "]\n");
			arrayOfTwoOrMorePositionsBegin = 1;
		}
	arr1 
	;
arrayOfTwoOrMorePositions2: '[' arrayOfTwoOrMorePositionsPosition2 ',' arrayOfTwoOrMorePositionsPosition2 pos2 ']' ;
pos2: | ',' arrayOfTwoOrMorePositionsPosition2 pos2 ;
arrayOfTwoOrMorePositionsPosition2:
	'[' NUM ',' NUM position0 ']'
	{
		if(arrayOfArrayOfTwoOrMorePositionsBegin == 1)
		{
			fprintf(file, "        var coords%d = [\n", coordsCounter);
			fprintf(file, "          [\n");
			fprintf(file, "            {lat: %f, lng: %f }", $4, $2);
			arrayOfArrayOfTwoOrMorePositionsBegin = 0;
			arrayOfTwoOrMorePositionsBegin = 0;
		}
		else if(arrayOfArrayOfTwoOrMorePositionsBegin != 1 && arrayOfTwoOrMorePositionsBegin == 1)
		{
			fprintf(file, "      ,    [\n");
			fprintf(file, "            {lat: %f, lng: %f }", $4, $2);
			arrayOfTwoOrMorePositionsBegin = 0;
		}
		else
		{
			fprintf(file, ",\n            {lat: %f, lng: %f }", $4, $2);
		}
	}
	;


arrayOfRings: '[' arrayOfRing0 ']' 
	{
		fprintf(file, "]");
	}
	;
arrayOfRing0: | ring2 arrayOfRing1 ;
arrayOfRing1:  | ',' ring2 arrayOfRing1 ;
ring2: '[' ringPosition2 ','  ringPosition2 ','  ringPosition2 ','  ringPosition2 rpos22 ']' ;
rpos22: | ',' ringPosition2 rpos22 ;
ringPosition2:
	'[' NUM ',' NUM position0 ']'
	{
		if(ringringBegin == 1)
		{
			fprintf(file, "        var coords%d = [\n", coordsCounter);
			fprintf(file, "          [\n");
			fprintf(file, "            {lat: %f, lng: %f }", $4, $2);
			ringBegin = 0;
			ringringBegin = 0;
		}
		else if(ringringBegin != 1 && ringBegin == 1)
		{
			fprintf(file, "      ,    [\n");
			fprintf(file, "            {lat: %f, lng: %f }", $4, $2);
			ringBegin = 0;
		}
		else
		{
			fprintf(file, ",\n            {lat: %f, lng: %f }", $4, $2);
		}
	}
	;
	




arrayOfArraysOfRings: '[' arrayOfArraysOfRings0 ']' ;
arrayOfArraysOfRings0: | arrayOfArraysOfRings1 ;
arrayOfArraysOfRings1: arrayOfRings | arrayOfRings ',' arrayOfArraysOfRings1 ;


members:  | member ',' members  ; 
members2: | ',' member members2 ;
member: NAME ':' memberValue ;
memberValue:
	  NAME 
	| NUM
	| '{' members1 '}'
	| genericList
	| COLOR
	| '"' '"'
	;
members1: | members11 ;
members11: member | member ',' members11 ;

genericList:
	'[' listG ']' ;
listG: listNUM | listNAME ;
listNUM: | lstNUM ;
lstNUM: NUM | NUM ',' lstNUM ;
listNAME: | lstNAME ;
lstNAME: NAME | NAME ',' lstNAME ;

point:
	  '{' members TYPE ':' POINT ',' members COORDINATES ':' pointPosition members2 '}'
		{
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.Point(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
		}
	| '{' members COORDINATES ':' pointPosition ',' members TYPE ':' POINT members2 '}'
		{
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.Point(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
		}
	;

multiPoint:
	  '{' members TYPE ':' MULTIPOINT ',' members COORDINATES ':' arrayOfPositions members2 '}'
		{
			/*
			I am aware of a fact that this way I create a set of points, not a multipoint.
			This production should work like other multi* productions.
			*/
			for (i = mainCoordsCounter; i < coordsCounter; i++)
			{
				fprintf(file, "        map.data.add({geometry: new google.maps.Data.Point(coords%d)});\n", i);
			}
			mainCoordsCounter = coordsCounter;
		}
	| '{' members COORDINATES ':' arrayOfPositions ',' members TYPE ':' MULTIPOINT members2 '}'
		{
			for (i = mainCoordsCounter; i < coordsCounter; i++)
			{
				fprintf(file, "        map.data.add({geometry: new google.maps.Data.Point(coords%d)});\n", i);
			}
			mainCoordsCounter = coordsCounter;
		}
	;

lineString:
	  '{' members TYPE ':' LINESTRING ',' members COORDINATES ':' arrayOfTwoOrMorePositions members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.LineString(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			arrayOfTwoOrMorePositionsBegin = 1;
		}
	| '{' members COORDINATES ':' arrayOfTwoOrMorePositions ',' members TYPE ':' LINESTRING members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.LineString(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			arrayOfTwoOrMorePositionsBegin = 1;
		}
	;

multiLineString:
	  '{' members TYPE ':' MULTILINESTRING ',' members COORDINATES ':' arraYOfArraysOfTwoOrMorePositions members2 '}'
		{
			fclose(file);
			file = fopen("./file.html", "a");
			


			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.MultiLineString(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			arrayOfTwoOrMorePositionsBegin = 1;
			arrayOfArrayOfTwoOrMorePositionsBegin = 1;
		}
	| '{' members COORDINATES ':' arraYOfArraysOfTwoOrMorePositions ',' members TYPE ':' MULTILINESTRING members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.MultiLineString(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			arrayOfTwoOrMorePositionsBegin = 1;
			arrayOfArrayOfTwoOrMorePositionsBegin = 1;
		}
	;

polygon:
	  '{' members TYPE ':' POLYGON ',' members COORDINATES ':' arrayOfRings members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.Polygon(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			ringBegin = 1;
			ringringBegin = 1;
		}
	| '{' members COORDINATES ':' arrayOfRings ',' members TYPE ':' POLYGON members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.Polygon(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			ringBegin = 1;
			ringringBegin = 1;
		}
	;

multiPolygon:
	  '{' members TYPE ':' MULTIPOLYGON ',' members COORDINATES ':' arrayOfArraysOfRings members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.MultiPolygon(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			ringBegin = 1;
			ringringBegin = 1;
		}
	| '{' members COORDINATES ':' arrayOfArraysOfRings ',' members TYPE ':' MULTIPOLYGON members2 '}'
		{
			fprintf(file, "\n        ];\n");
			fprintf(file, "        map.data.add({geometry: new google.maps.Data.MultiPolygon(coords%d)});\n", coordsCounter);
			coordsCounter += 1;
			mainCoordsCounter = coordsCounter;
			ringBegin = 1;
			ringringBegin = 1;
		}
	;

geometryCollection:
	  '{' members TYPE ':' GEOMETRYCOLLECTION ',' members GEOMETRIES ':' arrayOfGeometryObjects members2 '}'
	| '{' members GEOMETRIES ':' arrayOfGeometryObjects ',' members TYPE ':' GEOMETRYCOLLECTION members2 '}'
	;

arrayOfGeometryObjects: '[' arrayOfGeometryObjects0 ']' ;
arrayOfGeometryObjects0: | arrayOfGeometryObjects1 ;
arrayOfGeometryObjects1: geometry | geometry ',' arrayOfGeometryObjects1 ;

feature:
	  '{' members TYPE ':' FEATURE ',' members GEOMETRY ':' geometry ',' members PROPERTIES ':' properties members2 '}'
	| '{' members TYPE ':' FEATURE ',' members PROPERTIES ':' properties ',' members GEOMETRY ':' geometry members2 '}'
	| '{' members PROPERTIES ':' properties ',' members GEOMETRY ':' geometry ',' members TYPE ':' FEATURE members2 '}'
	| '{' members PROPERTIES ':' properties ',' members TYPE ':' FEATURE ',' members GEOMETRY ':' geometry members2 '}'
	| '{' members GEOMETRY ':' geometry ',' members PROPERTIES ':' properties ',' members TYPE ':' FEATURE members2 '}'
	| '{' members GEOMETRY ':' geometry ',' members TYPE ':' FEATURE ',' members PROPERTIES ':' properties members2 '}'
	;

properties: '{' properties0 '}' ;
properties0: | properties1 ;
properties1: property | property ',' properties1 ;
property: member | newObject;

featureCollection:
	  '{' members TYPE ':' FEATURECOLLECTION ',' members FEATURES ':' arrayOfFeatures members2 '}'
	| '{' members FEATURES ':' arrayOfFeatures ',' members TYPE ':' FEATURECOLLECTION members2 '}'
	;
arrayOfFeatures: '[' arrayOfFeatures0 ']' ;
arrayOfFeatures0: | arrayOfFeatures1 ;
arrayOfFeatures1: feature | feature ',' arrayOfFeatures1 ;
	
%%
int main(){

	file = fopen("./file.html", "w+");

	fprintf(file, "<!DOCTYPE html>\n");
	fprintf(file, "<html>\n");
	fprintf(file, "  <head>\n");
	fprintf(file, "    <title>Data Layer: Dynamic Styling</title>\n");
	fprintf(file, "    <meta name=\"viewport\" content=\"initial-scale=1.0\">\n");
	fprintf(file, "    <meta charset=\"utf-8\">\n");
	fprintf(file, "    <style>\n");
	fprintf(file, "      #map {\n");
	fprintf(file, "        height: 100%;\n");
	fprintf(file, "      }\n");
	fprintf(file, "      html, body {\n");
	fprintf(file, "        height: 100%;\n");
	fprintf(file, "        margin: 0;\n");
	fprintf(file, "        padding: 0;\n");
	fprintf(file, "      }\n");
	fprintf(file, "    </style>\n");
	fprintf(file, "  </head>\n");
	fprintf(file, "  <body>\n");
	fprintf(file, "    <div id=\"map\"></div>\n");
	fprintf(file, "    <script>\n");
	fprintf(file, "      var map;\n");
	fprintf(file, "      function initMap() {\n");
	fprintf(file, "        map = new google.maps.Map(document.getElementById('map'), {\n");
	fprintf(file, "          zoom: 3,\n");
	fprintf(file, "          center: {lat: 0, lng: 0}\n");
	fprintf(file, "        });\n");
	fprintf(file, "        map.data.setStyle(function(feature) {\n");
	fprintf(file, "          var color = 'pink';\n");
	fprintf(file, "          if (feature.getProperty('isColorful')) {\n");
	fprintf(file, "            color = feature.getProperty('color');\n");
	fprintf(file, "          }\n");
	fprintf(file, "          return /** @type {!google.maps.Data.StyleOptions} */({\n");
	fprintf(file, "            fillColor: color,\n");
	fprintf(file, "            strokeColor: color,\n");
	fprintf(file, "            strokeWeight: 2\n");
	fprintf(file, "          });\n");
	fprintf(file, "        });\n");
	fprintf(file, "        map.data.addListener('click', function(event) {\n");
	fprintf(file, "          event.feature.setProperty('isColorful', true);\n");
	fprintf(file, "        });\n");
	fprintf(file, "        map.data.addListener('mouseover', function(event) {\n");
	fprintf(file, "          map.data.revertStyle();\n");
	fprintf(file, "          map.data.overrideStyle(event.feature, {strokeWeight: 8});\n");
	fprintf(file, "        });\n");
	fprintf(file, "        map.data.addListener('mouseout', function(event) {\n");
	fprintf(file, "          map.data.revertStyle();\n");
	fprintf(file, "        });\n");
	fprintf(file, "\n");
	fprintf(file, "\n");
	//----------
	fprintf(file, "\n");
	fprintf(file, "/*GENERATED CODE*/\n");


	yyparse();


	fprintf(file, "\n");
	fprintf(file, "/*END OF GENERATED CODE*/\n");
	//----------
	fprintf(file, "\n");
	fprintf(file, "\n");
	fprintf(file, "      }\n");
	fprintf(file, "    </script>\n");
	fprintf(file, "    <script async defer\n");
	fprintf(file, "    src=\"https://maps.googleapis.com/maps/api/js?key=GOOGLEMAPSAPIKEY&callback=initMap\">\n");
	fprintf(file, "    </script>\n");
	fprintf(file, "  </body>\n");
	fprintf(file, "</html>\n");

	fprintf(file, "\n");

	fclose(file);
	
	return 0;
}
int yyerror(char *msg){
	fprintf(stderr,"%s\n",msg);
	return 0;
}
