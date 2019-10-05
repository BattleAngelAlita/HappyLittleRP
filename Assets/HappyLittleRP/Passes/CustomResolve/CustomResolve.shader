Shader "Hidden/CustomResolve"
{
	Properties
	{
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Pass
		{
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#include "UnityCG.cginc"
#pragma target 4.5

Texture2DMS<float, 4> _DepthBuffer;

float4 frag(v2f_img i) : SV_Target
{
	int2 loadUV = i.uv * _ScreenParams.xy;

	float sample0 = _DepthBuffer.Load(loadUV, 0);
	float sample1 = _DepthBuffer.Load(loadUV, 1);
	float sample2 = _DepthBuffer.Load(loadUV, 2);
	float sample3 = _DepthBuffer.Load(loadUV, 3);

	float depthMin = min(min(sample0, sample1), min(sample2, sample3));
	float depthMax = max(max(sample0, sample1), max(sample2, sample3));
	float depthAvg = (sample0 + sample1 + sample2 + sample3) * 0.25;

	float d = 0.0;
	if (i.uv.x < 0.33)
		d = depthMin;
	else if(i.uv.x < 0.66)
		d = depthMax;
	else
		d = depthAvg;

return d;
}
ENDCG
		}
	}
}