using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

[CreateAssetMenu]
public class GBuffer : HappyLittlePass
{
	public Material gGBufferMaterial;
	public Material finalMaterial;

	public override void Execute(ScriptableRenderContext context, Camera camera, CullingResults cullingResults)
	{
		//Vector3[] frustumCorners = new Vector3[4];
		//camera.CalculateFrustumCorners(new Rect(0, 0, 1, 1), camera.farClipPlane, Camera.MonoOrStereoscopicEye.Mono, frustumCorners);

		int depthBuffer = Shader.PropertyToID("_DepthBuffer");
		int gBuffer0    = Shader.PropertyToID("_GBuffer0");
		int gBuffer1    = Shader.PropertyToID("_GBuffer1");
		int gBufferT    = Shader.PropertyToID("_GBufferT");

		RenderTargetIdentifier depthBufferID = new RenderTargetIdentifier(depthBuffer);
		RenderTargetIdentifier gBuffer0ID    = new RenderTargetIdentifier(gBuffer0);
		RenderTargetIdentifier gBuffer1ID    = new RenderTargetIdentifier(gBuffer1);
		RenderTargetIdentifier gBufferTID    = new RenderTargetIdentifier(gBufferT);

		RenderTargetIdentifier[] gBuffeIDs = new RenderTargetIdentifier[3];

		RenderTextureDescriptor depthBufferDesc = new RenderTextureDescriptor(Screen.width, Screen.height, RenderTextureFormat.Depth, 32);
		RenderTextureDescriptor gBuffer0Desc    = new RenderTextureDescriptor(Screen.width, Screen.height, GraphicsFormat.R8G8B8A8_SRGB, 0);
		RenderTextureDescriptor gBuffer1Desc    = new RenderTextureDescriptor(Screen.width, Screen.height, GraphicsFormat.A2B10G10R10_UNormPack32, 0);
		RenderTextureDescriptor gBufferTDesc    = new RenderTextureDescriptor(Screen.width, Screen.height, GraphicsFormat.R32G32B32A32_SFloat, 0);
		//R8G8B8A8_UNorm
		//A2B10G10R10_UNormPack32
		//R5G6B5_UNormPack16
		//B5G5R5A1_UNormPack16

		CommandBuffer cmdClear = CommandBufferPool.Get("Clear");
		{
			cmdClear.GetTemporaryRT(depthBuffer, depthBufferDesc); //depth
			cmdClear.GetTemporaryRT(gBuffer0,    gBuffer0Desc);    //rgb - albedo, a - AO
			cmdClear.GetTemporaryRT(gBuffer1,    gBuffer1Desc);    //rg  - normal, b - roughness, a - metallic
			cmdClear.GetTemporaryRT(gBufferT,    gBufferTDesc);    //test data

			gBuffeIDs[0] = gBuffer0ID;
			gBuffeIDs[1] = gBuffer1ID;
			gBuffeIDs[2] = gBufferTID;

			cmdClear.SetRenderTarget(gBuffeIDs, depthBufferID);
			cmdClear.ClearRenderTarget(true, true, Color.black);
		}
		context.ExecuteCommandBuffer(cmdClear);
		CommandBufferPool.Release(cmdClear);


		//Fill GBuffer
		DrawingSettings drawingSettingss = new DrawingSettings(new ShaderTagId("GBuffer"), HappyLittleRP.opaqueSortingSettings) { perObjectData = PerObjectData.None };
		context.DrawRenderers(cullingResults, ref drawingSettingss, ref HappyLittleRP.opaqueFilteringSettings);


		//
		CommandBuffer cmdBlit = CommandBufferPool.Get("Blit");
		{
			cmdBlit.SetGlobalTexture(depthBuffer, depthBufferID);

			cmdBlit.SetGlobalTexture(gBuffer0, gBuffer0ID);
			cmdBlit.SetGlobalTexture(gBuffer1, gBuffer1ID);
			cmdBlit.SetGlobalTexture(gBufferT, gBufferTID);

			cmdBlit.Blit(null, BuiltinRenderTextureType.CameraTarget, finalMaterial);
		}
		context.ExecuteCommandBuffer(cmdBlit);
		CommandBufferPool.Release(cmdBlit);
	}
}
