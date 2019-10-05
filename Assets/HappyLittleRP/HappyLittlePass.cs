using UnityEngine;
using UnityEngine.Rendering;

public abstract class HappyLittlePass : ScriptableObject
{
	public abstract void Execute(ScriptableRenderContext context, Camera camera, CullingResults cullingResults);
}
