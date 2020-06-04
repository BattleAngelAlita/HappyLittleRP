Shader "Hidden/GBufferFinal"
{
	Properties {}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Pass
		{

HLSLPROGRAM
#pragma vertex vert_img
#pragma fragment frag

#include "UnityCG.cginc"
#include "Assets/HappyLittleRP/ShaderLibrary/HappyLittleLibrary.hlsl"

sampler2D _DepthBuffer;
sampler2D _GBuffer0;
sampler2D _GBuffer1;
sampler2D _GBufferT;

half4 frag(v2f_img i) : SV_Target
{
	half  depth   = tex2D(_DepthBuffer, i.uv);
	half4 albedo  = tex2D(_GBuffer0,    i.uv);
	half4 normalG = tex2D(_GBuffer1,    i.uv);
	half4 test    = tex2D(_GBufferT,    i.uv);

	half3 normal = Decode(normalG.xy);
	normal = normalize(normal);

	half3 lightDir = normalize(half3(1.0, 1.0, 1.0));
	half  nl = saturate(dot(normal, lightDir));

	half4 final = 0.0;
	final.rgb = albedo.rgb * nl;

return final;
}
ENDHLSL
		}
	}
}