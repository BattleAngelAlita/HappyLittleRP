using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu]
public class CoarseShading : HappyLittlePass
{
	public Material coarseBlitMaterial;

	public override void Execute(ScriptableRenderContext context, Camera camera, CullingResults cullingResults)
	{
		int frameBufferWidth  = 1024;
		int frameBufferHeight = 576;

		int msaaRT = Shader.PropertyToID("_MsaaBuffer");
		RenderTargetIdentifier  msaaRTID   = new RenderTargetIdentifier(msaaRT);
		RenderTextureDescriptor msaaRTDesc = new RenderTextureDescriptor(frameBufferWidth / 2, frameBufferHeight / 2, RenderTextureFormat.DefaultHDR);
		msaaRTDesc.msaaSamples = 4;
		msaaRTDesc.bindMS = true;

		int resolvedRT = Shader.PropertyToID("_ResolvedBuffer");
		RenderTargetIdentifier  resolvedRTID   = new RenderTargetIdentifier(resolvedRT);
		RenderTextureDescriptor resolvedRTDesc = new RenderTextureDescriptor(frameBufferWidth, frameBufferHeight, RenderTextureFormat.DefaultHDR);

		CommandBuffer cmd = CommandBufferPool.Get("MSAA");
		{
			cmd.GetTemporaryRT(msaaRT, msaaRTDesc);

			cmd.SetRenderTarget(msaaRTID);
			cmd.ClearRenderTarget(true, true, Color.clear);
		}
		context.ExecuteCommandBuffer(cmd);
		CommandBufferPool.Release(cmd);


		context.DrawRenderers(cullingResults, ref HappyLittleRP.opaqueDrawingSettings, ref HappyLittleRP.opaqueFilteringSettings);


		CommandBuffer cmdResolve = CommandBufferPool.Get("Resolve");
		{
			cmd.GetTemporaryRT(resolvedRT, resolvedRTDesc, FilterMode.Bilinear);

			cmdResolve.SetGlobalVector("_FrameBufferParams", new Vector4(frameBufferWidth, frameBufferHeight, 1.0f / frameBufferWidth, 1.0f / frameBufferHeight));
			cmdResolve.SetGlobalTexture(msaaRT, msaaRTID);
			cmdResolve.Blit(null, resolvedRTID, coarseBlitMaterial);
		}
		context.ExecuteCommandBuffer(cmdResolve);
		cmdResolve.Release();

		CommandBuffer cmdBlit = CommandBufferPool.Get("Blit");
		{
			cmdBlit.Blit(resolvedRTID, BuiltinRenderTextureType.CameraTarget);
		}
		context.ExecuteCommandBuffer(cmdBlit);
		cmdBlit.Release();
	}
}
