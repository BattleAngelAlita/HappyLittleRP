using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu]
public class CustomResolve : HappyLittlePass
{
	public Material customResolveMaterial;

	public override void Execute(ScriptableRenderContext context, Camera camera, CullingResults cullingResults)
	{

		int depthBuffer = Shader.PropertyToID("_DepthBuffer");
		RenderTargetIdentifier  depthBufferID   = new RenderTargetIdentifier(depthBuffer);
		RenderTextureDescriptor depthBufferDesc = new RenderTextureDescriptor(Screen.width, Screen.height, RenderTextureFormat.Depth, 32);
		depthBufferDesc.msaaSamples = 4;
		depthBufferDesc.bindMS = true;

		int colorBuffer = Shader.PropertyToID("_ColorBuffer");
		RenderTargetIdentifier  colorBufferID   = new RenderTargetIdentifier(colorBuffer);
		RenderTextureDescriptor colorBufferDesc = new RenderTextureDescriptor(Screen.width, Screen.height, RenderTextureFormat.DefaultHDR, 0);
		colorBufferDesc.msaaSamples = 4;
		colorBufferDesc.bindMS = true;


		CommandBuffer cmdClear = CommandBufferPool.Get("Clear");
		{
			cmdClear.GetTemporaryRT(depthBuffer, depthBufferDesc, FilterMode.Point);
			cmdClear.GetTemporaryRT(colorBuffer, colorBufferDesc, FilterMode.Point);

			cmdClear.SetRenderTarget(colorBufferID, depthBufferID);
			cmdClear.ClearRenderTarget(true, true, Color.clear);
		}
		context.ExecuteCommandBuffer(cmdClear);
		CommandBufferPool.Release(cmdClear);


		context.DrawRenderers(cullingResults, ref HappyLittleRP.opaqueDrawingSettings, ref HappyLittleRP.opaqueFilteringSettings);


		CommandBuffer cmdResolve = CommandBufferPool.Get("Resolve");
		{
			cmdResolve.SetGlobalTexture(depthBuffer, depthBufferID);
			cmdResolve.Blit(null, BuiltinRenderTextureType.CameraTarget, customResolveMaterial);
		}
		context.ExecuteCommandBuffer(cmdResolve);
		cmdResolve.Release();
	}
}
