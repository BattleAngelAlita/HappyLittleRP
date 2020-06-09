Shader "Hidden/CommonPasses"
{
	Properties
	{
		_MainTex           ("Texture",             2D) = "white" {}
		_NormalMap         ("Normal Map",          2D) = "bump"  {}
		_AmbientOcclusion  ("Ambient Occlusion",   2D) = "white" {}
		_MetallicSmoothness("Metallic Smoothness", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass
		{
			Name "GBuffer"
			Tags { "LightMode" = "GBuffer" }

HLSLPROGRAM
#pragma target 3.5
#pragma vertex vert
#pragma fragment frag

#pragma multi_compile _TEXTURELAYOUT_LEGACY _TEXTURELAYOUT_HAPPY

#include "UnityCG.cginc"
#include "Assets/HappyLittleRP/ShaderLibrary/HappyLittleLibrary.hlsl"

struct v2f
{
	float4 vertex  : SV_POSITION;
	float2 uv      : TEXCOORD0;

	float3 wPos    : TEXCOORD1;

	half3  tspace0 : TEXCOORD2;
	half3  tspace1 : TEXCOORD3;
	half3  tspace2 : TEXCOORD4;
};

struct GBufferOutput
{
	half4 rt0 : SV_TARGET0;
	half4 rt1 : SV_TARGET1;
	half4 rtT : SV_TARGET3;
};


sampler2D _MainTex;		float4 _MainTex_ST;
sampler2D _NormalMap;
sampler2D _AmbientOcclusion;
sampler2D _MetallicSmoothness;

v2f vert(appdata_tan v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

	half3 wPosVector;

	half3 wNormal = UnityObjectToWorldNormal(v.normal);
	half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
	half3 wBitangent = cross(wNormal, wTangent) * v.tangent.w * unity_WorldTransformParams.w;

	half3x3 worldToTangent = half3x3(wTangent, wBitangent, wNormal);

	half3 tPosVector = mul(worldToTangent, wPosVector);

	o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
	o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
	o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
return o;
}

GBufferOutput frag(v2f i) : SV_Target
{
	GBufferOutput o;

	half3 albedo = tex2D(_MainTex, i.uv);
	half  ao = tex2D(_AmbientOcclusion, i.uv);
	half4 ms = tex2D(_MetallicSmoothness, i.uv);

	//normal = normal * (255.0 / 127.0) - (128.0 / 127.0);
	half3 tNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
	half3 wNormal = 0.0;
	wNormal.x = dot(i.tspace0, tNormal);
	wNormal.y = dot(i.tspace1, tNormal);
	wNormal.z = dot(i.tspace2, tNormal);
	wNormal = normalize(wNormal);

	half3 vNormal = mul((half3x3)UNITY_MATRIX_V, wNormal);

	o.rt0 = half4(albedo, ao);
	o.rt1 = half4(Encode(vNormal), 1.0 - ms.a, ms.g);
	o.rtT = half4(vNormal, 0.0);

return o;
}
ENDHLSL
		}
	}
}
