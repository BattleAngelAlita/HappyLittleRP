using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
	using UnityEditor;
	using UnityEditorInternal;
#endif

//[Serializable]
//public struct MobWave
//{
//	public enum WaveType
//	{
//		Mobs,
//		Boss
//	}

//	public string name;
//	public WaveType Type;
//	public GameObject Prefab;
//	public int Count;
//}

[CreateAssetMenu]
public class HappyLittleAsset : RenderPipelineAsset
{
	//public List<MobWave> Waves = new List<MobWave>();
	public List<HappyLittlePass> Passes = new List<HappyLittlePass>();

	protected override RenderPipeline CreatePipeline()
	{
		return new HappyLittleRP(this);
	}
}

#if UNITY_EDITOR

[CustomEditor(typeof(HappyLittleAsset))]
public class HappyLittleAssetEditor : Editor
{
	private ReorderableList list;
	private Editor editor;

	private void OnEnable()
	{
		list = new ReorderableList(serializedObject,
				serializedObject.FindProperty("Passes"),
				true, true, true, true);

		//list = new ReorderableList(serializedObject,
		//		serializedObject.FindProperty("Waves"),
		//		true, true, true, true);
		//editors = new Editor[];

		HappyLittleAsset myTarget = target as HappyLittleAsset;

		list.drawElementCallback = (Rect rect, int index, bool isActive, bool isFocused) =>
		{
			var element = list.serializedProperty.GetArrayElementAtIndex(index);
			rect.y += 2;

			element.serializedObject.Update();
				EditorGUI.PropertyField(
					new Rect(rect.x, rect.y, rect.width, EditorGUIUtility.singleLineHeight),
					element, GUIContent.none);
			element.serializedObject.ApplyModifiedProperties();
		};

	}

	public override void OnInspectorGUI()
	{
		serializedObject.Update();
		list.DoLayoutList();
		serializedObject.ApplyModifiedProperties();
	}
}

#endif
