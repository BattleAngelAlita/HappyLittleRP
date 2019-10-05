using UnityEngine;
using UnityEngine.Rendering;

public class HappyLittleRP : RenderPipeline
{
	private HappyLittleAsset happyAsset;
	public HappyLittleRP(HappyLittleAsset asset)
	{
		happyAsset = asset;
	}

	ScriptableCullingParameters cullingParameters;
	public static FilteringSettings opaqueFilteringSettings      = new FilteringSettings(RenderQueueRange.opaque);
	public static FilteringSettings transparentFilteringSettings = new FilteringSettings(RenderQueueRange.transparent);

	public static SortingSettings opaqueSortingSettings = new SortingSettings() { criteria = SortingCriteria.CommonOpaque };
	public static DrawingSettings opaqueDrawingSettings = new DrawingSettings(new ShaderTagId("Happy"), opaqueSortingSettings) { perObjectData = PerObjectData.None };

	protected override void Render(ScriptableRenderContext context, Camera[] cameras)
	{
		if(happyAsset.Passes == null)
			return;
		if(happyAsset.Passes.Count == 0)
			return;

		foreach(Camera camera in cameras)
		{
#if UNITY_EDITOR
			if(camera.cameraType == CameraType.SceneView)
				ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
#endif

			camera.TryGetCullingParameters(out cullingParameters);
			CullingResults cullingResults = context.Cull(ref cullingParameters);

			context.SetupCameraProperties(camera);
			happyAsset.Passes[0].Execute(context, camera, cullingResults);

			context.Submit();
		}
	}
}
