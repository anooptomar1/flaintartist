//
//  point.vsh
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-08.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

attribute vec4 inVertex;

uniform mat4 MVP;
uniform float pointSize;
uniform lowp vec4 vertexColor;

varying lowp vec4 color;

void main()
{
    gl_Position = MVP * inVertex;
    gl_PointSize = pointSize;
    color = vertexColor;
}
