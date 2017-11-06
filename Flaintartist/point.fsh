//
//  point.fsh
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-08.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

uniform sampler2D texture;
varying lowp vec4 color;

void main()
{
    gl_FragColor = color * texture2D(texture, gl_PointCoord);
}

