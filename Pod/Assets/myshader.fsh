uniform sampler2D videoTex_y;
uniform sampler2D videoTex_u;
uniform sampler2D videoTex_v;
uniform sampler2D videoTex_uv;
mediump int imageWidth;
mediump int imageHeight;



varying mediump vec2 fragmentTextureCoordinates;

mediump int fmod(mediump int x, mediump int y) {
    return x - y * int(x/y);
}


void main()
{
    //gl_FragColor = texture2D(videoTex_y, fragmentTextureCoordinates);

    /*
    imageWidth = 512;
    imageHeight = 512;
    
    mediump int s = int(fragmentTextureCoordinates.x * float(imageWidth));
    mediump int t = int(fragmentTextureCoordinates.y * float(imageHeight));
    mediump int sizeTotal = int(imageWidth * imageHeight);

    mediump int uPos =  (t / 2) * (imageWidth / 2) + (s / 2);
    mediump int uCoordX = fmod(uPos, imageWidth);
    mediump int uCoordY = int(uPos / imageWidth);
    mediump vec2 uCoord = mediump vec2(float(uCoordX) / float(imageWidth), float(uCoordY) / float(imageHeight));

    mediump int vPos = (t / 2) * (imageWidth / 2) + (s / 2) + (sizeTotal / 4);
    mediump int vCoordX = fmod(vPos, imageWidth);
    mediump int vCoordY = int(vPos / imageWidth);
    mediump vec2 vCoord = mediump vec2(float(vCoordX) / float(imageWidth), float(vCoordY) / float(imageHeight));
     */
    
    /* yuv420 */
    mediump float  y = texture2D(videoTex_y, fragmentTextureCoordinates).x;
    mediump float  u = texture2D(videoTex_u, vec2(fragmentTextureCoordinates.x/2.0,fragmentTextureCoordinates.y/2.0)).x;
    mediump float  v = texture2D(videoTex_v, vec2(fragmentTextureCoordinates.x/2.0,fragmentTextureCoordinates.y/2.0)).x;
    
    
    y = 1.1643 * (y - 0.0625);
    u = u - 0.5;
    v = v - 0.5;
    
    mediump float r=y+1.5958 * v;
    mediump float g=y-0.39173 * u-0.81290 * v;
    mediump float b=y+2.017 * u;
    gl_FragColor = vec4(r, g, b, 1);
    
    //gl_FragColor = vec4(1., 0., 0., 1);
    /*
    if (s == 100 && t == 100 && uCoordY == 25 ) {
        gl_FragColor = vec4(1., 1., 1., 1);
        
    } else {
        gl_FragColor = vec4(0., 0., 0., 1);
        
    }
    */
    //gl_FragColor = vec4(y, y, y, 1.);
    //gl_FragColor = vec4(u, u, u, 1.);
    //gl_FragColor = vec4(v, v, v, 1.);

}
