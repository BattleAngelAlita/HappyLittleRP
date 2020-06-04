#ifndef HAPPYLITTLELIBRARY_INCLUDED
#define HAPPYLITTLELIBRARY_INCLUDED

half3 OctaHemiDecode(half2 coord)
{
	coord = half2(coord.x + coord.y, coord.x - coord.y) * 0.5;
	half3 vec = half3(coord.x, 1.0 - saturate(dot(half2(1.0, 1.0), abs(coord.xy))), coord.y);
return vec;
}

half2 OctWrap(half2 v)
{
	return (1.0 - abs(v.yx)) * (v.xy >= 0.0 ? 1.0 : -1.0);
}

half2 Encode(half3 n)
{
	n    = n / (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : OctWrap(n.xy);
	n.xy = n.xy * 0.5 + 0.5;
return n.xy;
}

half3 Decode(half2 f)
{
	f = f * 2.0 - 1.0;

	// https://twitter.com/Stubbesaurus/status/937994790553227264
	half3 n = half3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));
	half t = saturate(-n.z);
	n.xy += n.xy >= 0.0 ? -t : t;
return n;
}


/*
https://wickedengine.net/2019/09/22/improved-normal-reconstruction-from-depth/
half3 NormalFromDepth()
{
	half depth = texture_depth.SampleLevel(sampler_point_clamp, uv, 0).r;
	half3 P = reconstructPosition(uv, depth, InverseViewProjection);
	half3 normal = normalize(cross(ddx(P), ddy(P)));
return normal;
}

half3 reconstructPosition(half2 uv, half z, half4x4 InvVP)
{
	half x = uv.x * 2.0f - 1.0f;
	half y = (1.0 - uv.y) * 2.0f - 1.0f;
	half4 position_s = half4(x, y, z, 1.0f);
	half4 position_v = mul(InvVP, position_s);
return position_v.xyz / position_v.w;
}

NormalFromDepth() //Compute
half2 uv0 = uv; // center
half2 uv1 = uv + half2(1, 0) / depth_dimensions; // right
half2 uv1 = uv + half2(0, 1) / depth_dimensions; // top

half depth0 = texture_depth.SampleLevel(sampler_point_clamp, uv0, 0).r;
half depth1 = texture_depth.SampleLevel(sampler_point_clamp, uv1, 0).r;
half depth2 = texture_depth.SampleLevel(sampler_point_clamp, uv2, 0).r;

half3 P0 = reconstructPosition(uv0, depth0, InverseViewProjection);
half3 P1 = reconstructPosition(uv1, depth1, InverseViewProjection);
half3 P2 = reconstructPosition(uv2, depth2, InverseViewProjection);

half3 normal = normalize(cross(P2 - P0, P1 - P0));
*/

/*
https://atyuwen.github.io/posts/normal-reconstruction/
// Try reconstructing normal accurately from depth buffer.
// input DepthBuffer: stores linearized depth in range (0, 1).
// 5 taps on each direction: | z | x | * | y | w |, '*' denotes the center sample.
half3 ReconstructNormal(texture2D DepthBuffer, half2 spos: SV_Position)
{
	half2 stc = spos / ScreenSize;
	half depth = DepthBuffer.Sample(DepthBuffer_Sampler, stc).x;

	half4 H;
	H.x = DepthBuffer.Sample(DepthBuffer_Sampler, stc - half2(1 / ScreenSize.x, 0)).x;
	H.y = DepthBuffer.Sample(DepthBuffer_Sampler, stc + half2(1 / ScreenSize.x, 0)).x;
	H.z = DepthBuffer.Sample(DepthBuffer_Sampler, stc - half2(2 / ScreenSize.x, 0)).x;
	H.w = DepthBuffer.Sample(DepthBuffer_Sampler, stc + half2(2 / ScreenSize.x, 0)).x;
	half2 he = abs(H.xy * H.zw * rcp(2 * H.zw - H.xy) - depth);
	half3 hDeriv;
	if (he.x > he.y)
		hDeriv = Calculate horizontal derivative of world position from taps | z | x |
	else
		hDeriv = Calculate horizontal derivative of world position from taps | y | w |

	half4 V;
	V.x = DepthBuffer.Sample(DepthBuffer_Sampler, stc - half2(0, 1 / ScreenSize.y)).x;
	V.y = DepthBuffer.Sample(DepthBuffer_Sampler, stc + half2(0, 1 / ScreenSize.y)).x;
	V.z = DepthBuffer.Sample(DepthBuffer_Sampler, stc - half2(0, 2 / ScreenSize.y)).x;
	V.w = DepthBuffer.Sample(DepthBuffer_Sampler, stc + half2(0, 2 / ScreenSize.y)).x;
	half2 ve = abs(V.xy * V.zw * rcp(2 * V.zw - V.xy) - depth);
	half3 vDeriv;
	if (ve.x > ve.y)
		vDeriv = Calculate vertical derivative of world position from taps | z | x |
	else
		vDeriv = Calculate vertical derivative of world position from taps | y | w |

	return normalize(cross(hDeriv, vDeriv));
}

*/

#endif //HAPPYLITTLELIBRARY_INCLUDED
