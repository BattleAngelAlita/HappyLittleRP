using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu]
public class SimplePass : HappyLittlePass
{
	public override void Execute(ScriptableRenderContext context, Camera camera, CullingResults cullingResults)
	{
		CommandBuffer cmdClear = CommandBufferPool.Get("Clear");
		{
			cmdClear.ClearRenderTarget(true, true, Color.clear);
		}
		context.ExecuteCommandBuffer(cmdClear);
		CommandBufferPool.Release(cmdClear);

		context.DrawRenderers(cullingResults, ref HappyLittleRP.opaqueDrawingSettings, ref HappyLittleRP.opaqueFilteringSettings);
	}
}
