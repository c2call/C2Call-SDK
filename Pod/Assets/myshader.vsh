//
//  Shader.vsh
//  GLApp
//
//  Created by Michael Knecht on 23.03.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

//varying vec4 colorVarying;

attribute vec2 textureCoord;
varying vec2 fragmentTextureCoordinates;
uniform float translate;

void main()
{
    gl_Position = position;
    //gl_Position.y += sin(translate) / 2.0;
//    colorVarying = color;
    
    fragmentTextureCoordinates = textureCoord;
}
