Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_MainTex           ("Texture",             2D) = "white" {}
		_NormalMap         ("Normal Map",          2D) = "bump"  {}
		_AmbientOcclusion  ("Ambient Occlusion",   2D) = "white" {}
		_MetallicSmoothness("Metallic Smoothness", 2D) = "black" {}

		[KeywordEnum(Legacy, Happy)] _TextureLayout("Layout", Float) = 1.0

	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		LOD 1000

		Pass
		{
			Name "Happy"
			Tags { "LightMode" = "Happy" }

HLSLPROGRAM
#pragma target 3.5
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile _TEXTURELAYOUT_LEGACY _TEXTURELAYOUT_HAPPY

#include "UnityCG.cginc"

struct v2f
{
	float4 vertex : SV_POSITION;
	float2 uv     : TEXCOORD0;
};

sampler2D _MainTex;		float4 _MainTex_ST;

v2f vert(appdata_full v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv     = TRANSFORM_TEX(v.texcoord, _MainTex);
return o;
}

half4 frag(v2f i) : SV_Target
{
	half4 col = tex2D(_MainTex, i.uv);
return col;
}
ENDHLSL
		}
		UsePass "Hidden/CommonPasses/GBuffer"
	}
}
