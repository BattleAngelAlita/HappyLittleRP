Shader "Hidden/CoarseBlit"
{
	Properties{}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Pass
		{
HLSLPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma target 5.0

#include "UnityCG.cginc"

Texture2DMS<float, 4> _MsaaBuffer;
float4 _FrameBufferParams;

float4 frag(v2f_img i) : SV_Target
{
	uint2 loadUV  = i.uv * _FrameBufferParams.xy / 2.0;
	uint2 loadUV2 = i.uv * _FrameBufferParams.xy;

	uint sampleIndex = (loadUV2.x & 1) + 2 * (loadUV2.y & 1);
	float4 sample0 = _MsaaBuffer.Load(loadUV, sampleIndex);

	float4 col = sample0;
return col;
}
ENDHLSL
		}
	}
}
